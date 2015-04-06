//
// $Id$

package com.whirled.game;

/**
 * Dispatched when the state of the game has changed.
 */
public class StateChangedEvent extends WhirledGameEvent
{
    /** Indicates that the game has transitioned to a started state. */
    public static final String GAME_STARTED = "GameStarted";

    /** Indicates that the game has transitioned to a ended state. */
    public static final String GAME_ENDED = "GameEnded";

    /** Indicates that the turn has changed. */
    // TODO: move to own event?
    public static final String TURN_CHANGED = "TurnChanged";

    public StateChangedEvent (WhirledGame game, String type)
    {
        super(game);
        _type = type;
    }

    public String getType ()
    {
        return _type;
    }

    public String toString ()
    {
        return "[StateChangedEvent type=" + _type + "]";
    }

    protected String _type;
}
