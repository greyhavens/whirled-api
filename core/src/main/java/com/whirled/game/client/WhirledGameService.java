//
// $Id$

package com.whirled.game.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

import com.whirled.game.WhirledGame;

/**
 * Provides services for whirled games.
 */
public interface WhirledGameService extends InvocationService
{
    /**
     * Request to end the turn, possibly futzing the next turn holder unless -1 is specified for
     * the nextPlayerIndex.
     */
    public void endTurn (Client client, int nextPlayerId, InvocationListener listener);

    /**
     * Requests to end the current round. If nextRoundDelay is greater than zero, the next round
     * will be started in the specified number of seconds.
     */
    public void endRound (Client client, int nextRoundDelay, InvocationListener listener);

    /**
     * Ends the active game, declaring the specified players to be winners and losers and paying
     * out coins using the specified payout type (defined in {@link WhirledGame}).
     */
    public void endGameWithWinners (Client client, int[] winners, int[] losers, int payoutType,
                                    InvocationListener listener);

    /**
     * Ends the active game, using the supplied scores to determine the base payouts and new
     * ratings and paying out coins using the specified payout type (defined in {@link
     * WhirledGame}).
     */
    public void endGameWithScores (Client client, int[] playerIds, int[] scores, int payoutType,
                                   int gameMode, InvocationListener listener);

    /**
     * Requests to start the game again in the specified number of seconds. This should only be
     * used for party games. Seated table games should have each player report that they are ready
     * again and the game will automatically start.
     */
    public void restartGameIn (Client client, int seconds, InvocationListener listener);

    /**
     * Ask the dictionary service for a set of random letters appropriate for the given
     * language/culture settings. These will be returned via a message back to the caller.
     *
     * @param client stores information about the caller
     * @param locale is an RFC 3066 string specifying language settings, for example, "en" or
     * "en-us".
     * @param dictionary is a String specifier of the dictionary to use, or null for the default.
     * @param count is the number of letters to be returned.
     * @param listener is the callback function
     */
    public void getDictionaryLetterSet (
        Client client, String locale, String dictionary, int count, ResultListener listener);
 
    /**
     * Ask the dictionary service for a set of random words appropriate for the given
     * language/culture settings. These will be returned via a message back to the caller.
     *
     * @param client stores information about the caller
     * @param locale is an RFC 3066 string specifying language settings, for example, "en" or
     * "en-us".
     * @param dictionary is a String specifier of the dictionary to use, or null for the default.
     * @param count is the number of words to be returned.
     * @param listener is the callback function
     */
    public void getDictionaryWords (
        Client client, String locale, String dictionary, int count, ResultListener listener);

    /**
     * Ask the dictionary service whether the specified word is valid with the given
     * language/culture settings. The result will be returned via a message back to the caller.
     *
     * @param client stores information about the caller
     * @param locale is an RFC 3066 string specifying language settings, for example, "en" or
     * "en-us".
     * @param dictionary is a String specifier of the dictionary to use, or null for the default.
     * @param word is the word to be checked against the dictionary.
     * @param listener is the callback function
     */
    public void checkDictionaryWord (
        Client client, String locale, String dictionary, String word, ResultListener listener);

    /**
     * Add to the specified named collection.
     *
     * @param clearExisting if true, wipe the old contents.
     */
    public void addToCollection (Client client, String collName, byte[][] data,
                                 boolean clearExisting, InvocationListener listener);

    /**
     * Merge the specified collection into the other.
     */
    public void mergeCollection (
        Client client, String srcColl, String intoColl, InvocationListener listener);

    /**
     * Pick or deal some number of elements from the specified collection, and either set a
     * property in the flash object, or deliver the picks to the specified player id via a game
     * message. The call will only succeed if the named collection exists and has enough members 
     * to deal the requested amount.
     */
    public void getFromCollection (Client client, String collName, boolean consume, int count,
                                   String msgOrPropName, int playerId, ConfirmListener listener);

    /**
     * Start a ticker that will send out timestamp information at the interval specified.
     *
     * @param msOfDelay must be at least 50, or 0 may be set to halt and clear a previously started
     * ticker.
     */
    public void setTicker (
        Client client, String tickerName, int msOfDelay, InvocationListener listener);

    /**
     * Request to get the specified user's cookie.
     */
    public void getCookie (Client client, int playerId, InvocationListener listener);

    /**
     * Request to set our cookie.
     */
    public void setCookie (Client client, byte[] cookie, int playerId, InvocationListener listener);

    /**
     * Requests that the specified player be marked as an AI. This is used by a game's server code
     * if it wishes to take over for a departed player in a multiplayer game.
     */
    public void makePlayerAI (Client client, int playerId, InvocationListener listener);
}
