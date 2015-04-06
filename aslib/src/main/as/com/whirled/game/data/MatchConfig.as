//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.io.SimpleStreamableObject;

/**
 * Used to configure the match-making interface for a game. Particular match-making mechanisms
 * extend this class and specify their own special configuration parameters.
 */
public /*abstract*/ class MatchConfig extends SimpleStreamableObject
{
    public function MatchConfig ()
    {
    }

    /** Returns the matchmaking type to use for this game, e.g. <code>GameConfig.SEATED_GAME</code>. */
    public function getMatchType () :int
    {
        throw new Error("Abstract");
    }

    /** Returns the minimum number of players needed to play this game. */
    public function getMinimumPlayers () :int
    {
        throw new Error("Abstract");
    }

    /** Returns the maximum number of players permitted to play this game. */
    public function getMaximumPlayers () :int
    {
        throw new Error("Abstract");
    }
}
}
