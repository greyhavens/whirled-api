//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game {

import flash.events.Event;

/**
 * Dispatched when the state of the game has changed.
 */
public class StateChangedEvent extends Event
{
    /**
     * Indicates that the game has transitioned to a started state.
     * @eventType GameStarted
     */
    public static const GAME_STARTED :String = "GameStarted";

    /**
     * Indicates that the game has transitioned to a ended state.
     * @eventType GameEnded
     */
    public static const GAME_ENDED :String = "GameEnded";

    /**
     * Indicates that a round has started. Games that do not require multiple rounds can ignore
     * this event.
     * @eventType RoundStarted
     */
    public static const ROUND_STARTED :String = "RoundStarted";

    /**
     * Indicates that the current round has ended.
     * @eventType RoundEnded
     */
    public static const ROUND_ENDED :String = "RoundEnded";

    /**
     * Indicates that a new controller has been assigned.
     * @eventType ControlChanged
     */
    public static const CONTROL_CHANGED :String = "ControlChanged";

    /** Indicates that the turn has changed.
     * @eventType TurnChanged
     */
    public static const TURN_CHANGED :String = "TurnChanged";

    public function StateChangedEvent (type :String)
    {
        super(type);
    }

    override public function toString () :String
    {
        return "[StateChangedEvent type=" + type + "]";
    }

    override public function clone () :Event
    {
        return new StateChangedEvent(type);
    }
}
}
