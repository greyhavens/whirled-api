//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import flash.events.Event;

import com.whirled.avrg.AVRGameControlEvent;

/**
 * Conveys information about a change to the state of a particular player in an AVR game.
 * @see PlayerSubControlClient
 * @see PlayerSubControlServer
 */
public class AVRGamePlayerEvent extends AVRGameControlEvent
{
    /**
     * An event type dispatched when the player receives some coins.
     * <br><b>name</b> - the id of the task that was completed
     * <br><b>value :int</b> - the amount of coins awarded
     *
     * @eventType taskCompleted
     */
    public static const TASK_COMPLETED :String = "taskCompleted";

    /**
     * An event type dispatched when the player has entered a new room.
     * <br><b>name</b> - not used
     * <br><b>value :int</b> - the id of the scene entered
     *
     * @eventType enteredRoom
     */
    public static const ENTERED_ROOM :String = "enteredRoom";

    /**
     * An event type dispatched when the player leaves a room.
     * <br><b>key</b> - not used
     * <br><b>value :int</b> - the id of the scene left
     *
     * @eventType leftRoom
     */
    public static const LEFT_ROOM :String = "leftRoom";

    /**
     * Creates a new AVRGamePlayerEvent.
     */
    public function AVRGamePlayerEvent (
        type :String, playerId :int, name :String = null, value :Object = null,
        cancelable :Boolean = false)
    {
        super(type, name, value, cancelable);
        _playerId = playerId;
    }

    /**
     * Gets the id of the target player whose state is changing.
     */
    public function get playerId () :int
    {
        return _playerId;
    }

    /** @inheritDoc */
    // from Event
    override public function toString () :String
    {
        return "AVRGamePlayerEvent [type=" + type + ", playerId=" + playerId + ", name=" + _name +
            ", value=" + _value + ", cancelable=" + cancelable + "]";
    }

    /** @inheritDoc */
    // documentation inherited from Event
    override public function clone () :Event
    {
        return new AVRGamePlayerEvent(type, _playerId, _name, _value, cancelable);
    }

    /** @private */
    protected var _playerId :int;
}
}
