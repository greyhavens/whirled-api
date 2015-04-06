//
// $Id$

package com.whirled.game.server;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import java.util.Map;
import java.util.Set;
import java.util.zip.GZIPInputStream;

import com.google.common.collect.HashMultiset;
import com.google.common.collect.Maps;
import com.google.common.collect.Multiset;
import com.google.common.collect.Sets;
import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.samskivert.util.CollectionUtil;
import com.samskivert.util.Invoker;
import com.samskivert.util.RandomUtil;

import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.InvocationService;

import static com.whirled.game.Log.log;

/**
 * Manages loading and querying word dictionaries in multiple languages.
 *
 * NOTE: This should probably be changed so that the loading of a dictionary occurs on
 * another thread (the invoker is perhaps not the best), but once loaded, everything should
 * probably be done on the dobj thread, unless I'm missing something.
 *
 * TODO: This shouldn't take InvocationListeners, it should take ResultListeners and users
 * of this service can adapt into InvocationListeners.
 *
 * NOTE: the service supports lazy loading of language files, but does not _unload_ them from
 * memory, leading to increasing memory usage.
 *
 * NOTE: the dictionary service has not yet been tested with language files written in non-default
 * character encodings.
 */
@Singleton
public class DictionaryManager
{
    /**
     * Initializes the singleton dictionary manager.
     *
     * @param prefix used to resolve dictionary word files like so:
     * <code>prefix/locale/wordlist.gz</code>
     */
    public void init (String prefix)
    {
        _prefix = prefix;
    }

    /**
     * Returns true if the language is known to be supported by the dictionary service (would it be
     * better to return a whole list of supported languages instead?)
     */
    public void isLanguageSupported (final String locale,
                                     final InvocationService.ResultListener listener)
    {
        // TODO: once we have file paths set up, change this to match against dictionary files
        listener.requestProcessed(locale != null && locale.toLowerCase().startsWith("en"));
    }

    /**
     * Retrieves a set of letters from a language definition file, and returns a random sampling of
     * /count/ elements.
     */
    public void getLetterSet (final String locale, final String dictionary, final int count,
                              final InvocationService.ResultListener listener)
    {
        _invoker.postUnit(new Invoker.Unit("DictionaryManager.getLetterSet") {
            public boolean invoke () {
                Dictionary dict = getDictionary(locale, dictionary);
                // TODO: see note in header. We should return a char[] directly, and
                // users of this class can take care of transforming it into flash-land.
                char[] chars = dict.pickRandomLetters(count);
                StringBuilder sb = new StringBuilder();
                for (char c : chars) {
                    sb.append(c);
                    sb.append(',');
                }
                sb.deleteCharAt(sb.length() - 1);
                _set = sb.toString();
                return true;
            }
            public void handleResult () {
                listener.requestProcessed(_set);
            }
            protected String _set;
        });
    }

    /**
     * Retrieves a list of words from a language definition file, and returns a random sampling of
     * /count/ elements.
     */
    public void getWords (final String locale, final String dictionary, final int count,
                          final InvocationService.ResultListener listener)
    {
        _invoker.postUnit(new Invoker.Unit("DictionaryManager.getWords") {
            public boolean invoke () {
                Dictionary dict = getDictionary(locale, dictionary);
                _set = dict.pickRandomWords(count);
                return true;
            }
            public void handleResult () {
                listener.requestProcessed(_set);
            }
            protected String[] _set;
        });
    }

    /**
     * Checks if the specified word exists in the given language
     */
    public void checkWord (final String locale, final String dictionary, final String word,
                           final InvocationService.ResultListener listener)
    {
        _invoker.postUnit(new Invoker.Unit("DictionaryManager.checkWord") {
            public boolean invoke () {
                Dictionary dict = getDictionary(locale, dictionary);
                _result = (dict != null && dict.contains(word));
                return true;
            }
            public void handleResult () {
                listener.requestProcessed(_result);
            }
            protected boolean _result;
        });
    }

    /**
     * Retrieves the dictionary object for a given locale.  Forces the dictionary file to be
     * loaded, if it hasn't already.
     */
    protected Dictionary getDictionary (String locale, String dictionary)
    {
        if (locale == null) {
            locale = "en-US";
        }

        String key = locale;

        if (dictionary != null) {
            key += "_";
            key += dictionary;
        }

        key = key.toLowerCase();
        // No funny business with the client supplied path
        key.replace(".", "");

        if (!_dictionaries.containsKey(key)) {
            String path = _prefix + "/" + key + ".wordlist.gz";
            try {
                InputStream in = getClass().getClassLoader().getResourceAsStream(path);
                _dictionaries.put(key, new Dictionary(locale, dictionary, new GZIPInputStream(in)));
            } catch (Exception e) {
                log.warning("Failed to load dictionary", "path", path, e);
            }
        }
        return _dictionaries.get(key);
    }

    /**
     * Helper class, encapsulates a sorted array of word hashes, which can be used to look up the
     * existence of a word.
     */
    protected class Dictionary
    {
        /**
         * Constructor, loads up the word list and initializes storage.  This naive version assumes
         * language files are simple list of words, with one word per line.
         */
        public Dictionary (String locale, String dictionary, InputStream words)
            throws IOException
        {
            Multiset<Character> letters = HashMultiset.create();

            if (words != null) {
                BufferedReader reader = new BufferedReader(new InputStreamReader(words));
                String line = null;
                while ((line = reader.readLine()) != null) {
                    String word = line.toLowerCase();
                    // add the word to the dictionary
                    _words.add(word);
                    // then count characters
                    for (int ii = word.length() - 1; ii >= 0; ii--) {
                        letters.add(word.charAt(ii));
                    }
                }

            } else {
                log.warning("Missing dictionary file", "locale", locale, "dict", dictionary);
            }

            initializeLetterCounts(letters);

            log.debug("Loaded dictionary", "locale", locale, "dictionary", dictionary,
                "words", _words.size(), "letters", letters);
        }

        /** Checks if the specified word exists in the word list */
        public boolean contains (String word)
        {
            return (word != null) && _words.contains(word.toLowerCase());
        }

        /** Gets an array of random letters for the language, with uniform distribution. */
        public char[] pickRandomLetters (int count)
        {
            char[] results = new char[count];
            for (int i = 0; i < count; i++) {
                // find random index and get its letter
                int index = RandomUtil.getWeightedIndex(_counts);
                results[i] = _letters[index];
            }

            return results;
        }

        public String[] pickRandomWords (int count)
        {
            return CollectionUtil.selectRandomSubset(_words, count).toArray(new String[count]);
        }

        // PROTECTED HELPERS

        /** Given a CountHashMap of letters, initializes the internal letter and count arrays, used
         * by RandomUtil. */
        protected void initializeLetterCounts (Multiset<Character> letters)
        {
            Set<Multiset.Entry<Character>> entrySet = letters.entrySet();
            int keycount = entrySet.size();

            // Initialize storage
            _letters = new char[keycount];
            _counts = new float[keycount];

            int total = 0;
            for (Multiset.Entry<Character> entry : entrySet) {
                keycount--;
                _letters[keycount] = entry.getElement();
                total += (_counts[keycount] = entry.getCount());
            }
            if (total == 0) { return; } // Something went wrong, abort.

            // normalize counts
            for (int ii = 0, nn = _counts.length; ii < nn; ii++) {
                _counts[ii] /= total;
            }
        }

        /** The words. */
        protected Set<String> _words = Sets.newHashSet();

        /** Letter array. */
        protected char[] _letters;

        /** Letter count array. */
        protected float[] _counts;
    }

    /** Used to locate dictionaries in the classpath. */
    protected String _prefix;

    /** Map from locale name to Dictionary object. */
    protected Map<String, Dictionary> _dictionaries = Maps.newHashMap();

    /** The invoker on which we load our dictionary files. */
    @Inject protected @MainInvoker Invoker _invoker;
}
