//
// $Id$

package com.whirled.game.data;

import com.threerings.util.StreamableHashMap;

/**
 * A game config for a simple multiplayer game, supplied to thane clients.
 */
public class ThaneGameConfig extends BaseGameConfig
{
    /** A zero argument constructor used when unserializing. */
    public ThaneGameConfig ()
    {
    }

    /** Constructs a game config based on the supplied game definition. */
    public ThaneGameConfig (
        int gameId, GameDefinition gameDef, StreamableHashMap<String, Object> inParams)
    {
        super(gameId, gameDef, inParams);
    }
}
