//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;

import com.whirled.avrg.RoomSubControlBase;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.PropertySubControlImpl;

/**
 * Dispatched when a room has unloaded and is no longer accessible. Note that once this has
 * happened, any further API methods called (except getRoomId()) will throw errors and no
 * further events will be dispatched on it. The purpose of this event is for local cleanup,
 * deregistration of event listeners, clearing out data structures and the like.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.ROOM_UNLOADED
 */
[Event(name="roomUnloaded", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Provides AVR services for a single room to server agents only.
 * @see AVRServerGameControl#getRoom()
 */
public class RoomSubControlServer extends RoomSubControlBase
    implements MessageSubControl
{
    /** @private */
    public function RoomSubControlServer (ctrl :AbstractControl, targetId :int)
    {
        super(ctrl, targetId);
    }

    /**
     * Accesses the properties for this room. Room properties marked as such will be persisted
     * and restored whenever the room is occupied anew.
     *
     * @see com.whirled.net.NetConstants#makePersistent()
     */
    public function get props () :PropertySubControl
    {
        return _props;
    }

    /** @inheritDoc */
    // from RoomSubControlBase
    override public function getRoomId () :int
    {
        return _targetId;
    }

    /**
     * Creates a new MOB in this room. The id identifies the instance of the MOB and the name
     * specifies the type. The call will do nothing if a MOB already exists in this room with the
     * given id. The coordinates specify the initial location of the MOB in room coordinates. The
     * visual representation of the MOB is created on the clients using the client's sprite exporter
     * callback.
     * @see LocalSubControl#setMobSpriteExporter()
     * @see #despawnMob()
     * @see RoomSubControlBase#getSpawnedMobs()
     * @see http://wiki.whirled.com/Coordinate_systems
     * @see RoomSubControlBase#event:mobControlAvailable
     */
    public function spawnMob (id :String, name :String, x :Number, y :Number, z :Number) :void
    {
        callHostCode("spawnMob_v1", id, name, x, y, z);
    }

    /**
     * Destroys a previosuly spawned MOB in this room.
     * @see #spawnMob()
     */
    public function despawnMob (id :String) :void
    {
        callHostCode("despawnMob_v1", id);
    }

    /**
     * Gets a MOB previously spawned in this room with the given id. Null is returned if there is
     * no MOB with that id.
     */
    public function getMobSubControl (id :String) :MobSubControlServer
    {
        return _mobControls[id] as MobSubControlServer;
    }

    /**
     * Sends a message to all the players that are in the room. Clients receive the message by
     * listening for <code>MESSAGE_RECEIVED</code> on <code>RoomSubControlClient</code>.
     * @see RoomSubControlClient#event:MsgReceived
     */
    public function sendMessage (name :String, value :Object = null) :void
    {
        callHostCode("room_sendMessage_v1", name, value);
    }

    /**
     * Sends a signal to all instances of all entities in the room. The same size restrictions as
     * EntityControl.sendSignal() apply here too.
     * @see com.whirled.EntityControl#sendSignal()
     */
    public function sendSignal (name :String, value :Object = null) :void
    {
        callHostCode("room_sendSignal_v1", name, value);
    }

    /** @private */
    override public function gotHostProps (o :Object) :void
    {
        super.gotHostProps(o);

        // Make sure we create all the mob controls that happen to be lying around in this room. 
        // Also delay the event dispatch because they are useless when called during construction
        // of the dispatcher!
        var delayEvent :Boolean = true;
        var mobIds :Array = callHostCode("getSpawnedMobs_v1") as Array;
        for each (var mobId :String in mobIds) {
            setMobSubControl(mobId, new MobSubControlServer(this, mobId), delayEvent);
        }
    }

    /** @private -- relayed from AVRServerGameControl when mob spawn is successful. */
    internal function mobSpawned_v1 (mobId :String) :void
    {
        // TODO: we should also report server-side MOB spawning errors to the game
        var delayEvent :Boolean = false;
        setMobSubControl(mobId, new MobSubControlServer(this, mobId), delayEvent);
    }

    /** @private -- relayed from AVRServerGameControl when signal received. */
    internal function roomUnloaded_v1 () :void
    {
        dispatchEvent(new AVRGameRoomEvent(AVRGameRoomEvent.ROOM_UNLOADED, _targetId));
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertySubControlImpl(
            _parent, _targetId, "room_getGameData_v1", "room_setProperty_v1");
        return [ _props ];
    }

    /** @private */
    protected var _props :PropertySubControl;
}
}
