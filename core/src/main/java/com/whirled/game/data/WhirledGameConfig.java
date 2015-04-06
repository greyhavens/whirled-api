//
// $Id$

package com.whirled.game.data;

/**
 * A game config for a simple multiplayer game, supplied to flash or java clients.
 */
public class WhirledGameConfig extends BaseGameConfig
{
    /** A zero argument constructor used when unserializing. */
    public WhirledGameConfig ()
    {
    }

    /** Constructs a game config based on the supplied game definition. */
    public WhirledGameConfig (int gameId, GameDefinition gameDef)
    {
        super(gameId, gameDef, null);
    }
}
