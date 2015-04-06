//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import flash.events.Event;

import com.whirled.avrg.AVRGameControlEvent;

/**
 * Conveys information about a change to the state of a particular room in an AVR game.
 * @see RoomSubControlClient
 * @see RoomSubControlServer
 */
public class AVRGameRoomEvent extends AVRGameControlEvent
{
    /**
     * An event type dispatched when a player entered the room.
     * <br/><b>name</b> - not used
     * <br/><b>value :int</b> - the id of the player entering
     *
     * @eventType playerEntered
     */
    public static const PLAYER_ENTERED :String = "playerEntered";

    /**
     * An event type dispatched either when a player leaves the room.
     * <br/><b>name</b> - not used
     * <br/><b>value :int</b> - the id of the player leaving
     *
     * @eventType playerLeft
     */
    public static const PLAYER_LEFT :String = "playerLeft";

    /**
     * An event type dispatched when a player of our game who's also in the room took up a new
     * location.
     * <br/><b>name</b> - not used
     * <br/><b>value :int</b> - the id of the player who moved
     *
     * @eventType playerMoved
     */
    public static const PLAYER_MOVED :String = "playerMoved";

    /**
     * An event type dispatched when something has changed about an avatar in the room.
     * <br/><b>name</b> - not used
     * <br/><b>value :int</b> - id of the player whose avatar changed
     *
     * @eventType avatarChanged
     * @see RoomSubControlBase#getAvatarInfo()
     */
    public static const AVATAR_CHANGED :String = "avatarChanged";

    /**
     * An event type dispatched when the control for a MOB spawned in the room has become available.
     * <br/><b>name</b> - the id of the MOB
     * <br/><b>value :MobSubControlBase</b> - the new control
     *
     * @eventType mobControlAvailable
     * @see RoomSubControlServer#spawnMob()
     * @see MobSubControlServer
     * @see MobSubControlClient
     */
    public static const MOB_CONTROL_AVAILABLE :String = "mobControlAvailable";

    /**
     * An event type dispatched when a signal has been received in this room.
     * <br/><b>name</b> - The name of the signal.
     * <br/><b>value</b> - The arg sent with the signal, or null.
     *
     * @eventType signalReceived
     * @see com.whirled.EntityControl#sendSignal()
     */
    public static const SIGNAL_RECEIVED :String = "signalReceived";

    /**
     * Dispatched when a room has unloaded and is no longer accessible. Note that once this has
     * happened, any further API methods called (except getRoomId()) will throw errors and no
     * further events will be dispatched on it. The purpose of this event is for local cleanup,
     * deregistration of event listeners, clearing out data structures and the like.
     *
     * @eventType com.whirled.avrg.AVRGameRoomEvent.ROOM_UNLOADED
     */
    public static const ROOM_UNLOADED :String = "roomUnloaded";

    /**
     * Creates a new AVRGameRoomEvent.
     */
    public function AVRGameRoomEvent (
        type :String, roomId :int, name :String = null, value :Object = null)
    {
        super(type, name, value);
        _roomId = roomId;
    }

    /**
     * Gets the id of the room whose state is changing.
     */
    public function get roomId () :int
    {
        return _roomId;
    }

    /** @inheritDoc */
    // from Event
    override public function toString () :String
    {
        return "AVRGameRoomEvent [type=" + type + ", roomId=" + roomId +
            ", name=" + _name + ", value=" + _value + "]";
    }

    /** @inheritDoc */
    // documentation inherited from Event
    override public function clone () :Event
    {
        return new AVRGameRoomEvent(type, _roomId, _name, _value);
    }

    /** @private */
    protected var _roomId :int;
}
}
