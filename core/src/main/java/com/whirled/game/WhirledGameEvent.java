//
// $Id$

package com.whirled.game;

public class WhirledGameEvent
{
    public WhirledGameEvent (WhirledGame game)
    {
        _game = game;
    }

    /**
     * Access the game object to which this event applies.
     */
    public WhirledGame getGameObject ()
    {
        return _game;
    }

    /** The game object for this event. */
    protected WhirledGame _game;
}
