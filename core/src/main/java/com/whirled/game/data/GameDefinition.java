//
// $Id$

package com.whirled.game.data;

import java.util.List;

import com.samskivert.util.StringUtil;

import com.threerings.io.Streamable;
import com.threerings.util.ActionScript;

import com.threerings.parlor.data.Parameter;

/**
 * Contains the information about a game as described by the game definition XML file.
 */
public abstract class GameDefinition implements Streamable
{
    /** A string identifier for the game. */
    public String ident;

    /** The class name of the <code>GameController</code> derivation that we use to bootstrap on
     * the client. */
    public String controller;

    /** The class name of the <code>GameManager</code> derivation that we use to manage the game on
     * the server. */
    public String manager;

    /** The MD5 digest of the game media file. */
    public String digest;

    /** The configuration of the match-making mechanism. */
    public MatchConfig match;

    /** Parameters used to configure the game itself. */
    public Parameter[] params;

    /** The class name to use when launching the game's agent using 
     * {@link com.threerings.bureau.server.BureauRegistry#startAgent}. */
    public String server;

    /**
     * Provides the path to this game's media (a jar file or an SWF).
     *
     * @param gameId the unique id of the game provided when this game definition was registered
     * with the system, or -1 if we're running in test mode.
     */
    public abstract String getMediaPath (int gameId);

    /**
     * Provides the path to this game's server media (an abc file). Returns null by default. 
     * Modules that want to support running game code on the server should override this method.
     *
     * @param gameId the unique id of the game provided when this game definition was registered
     * with the system, or -1 if we're running in test mode.
     * @return the path or null if no server media is required for this game.
     */
    public String getServerMediaPath (int gameId)
    {
        return null;
    }

    /**
     * Provides the id of this game's bureau when running server-side code. Returns "default" by 
     * default. Modules that want to support running game code on the server should override this 
     * method. The plan is currently to use the persistent id of the game so that each body of 
     * user code is isolated within a bureau. 
     *
     * <p>Note: the bureau id will eventually be used as the path to a log file so must not contain
     * separator characters or other inappropriate punctuation.
     *
     * @param gameId the unique id of the game provided when this game definition was registered
     * with the system, or -1 if we're running in test mode.
     * @return the id of the bureau in which to run this game, if required
     */
    public String getBureauId (int gameId)
    {
        return "default";
    }

    /**
     * Returns true if a single player can play this game (possibly against AI opponents), or if
     * opponents are needed.
     */
    public boolean isSinglePlayerPlayable ()
    {
        // maybe it's just single player no problem
        int minPlayers = 2;
        if (match != null) {
            minPlayers = match.getMinimumPlayers();
            if (minPlayers <= 1) {
                return true;
            }
        }

        // or maybe it has AIs
        int aiCount = 0;
        for (Parameter param : params) {
            if (param instanceof AIParameter) {
                aiCount = ((AIParameter)param).maximum;
            }
        }
        return (minPlayers - aiCount) <= 1;
    }

    /** Called when parsing a game definition from XML. */
    @ActionScript(omit=true)
    public void setParams (List<Parameter> list)
    {
        params = list.toArray(new Parameter[list.size()]);
    }

    /** Generates a string representation of this instance. */
    public String toString ()
    {
        return StringUtil.fieldsToString(this);
    }
}
