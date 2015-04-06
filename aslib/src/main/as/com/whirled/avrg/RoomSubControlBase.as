//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

import com.threerings.util.Log;

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.ControlEvent;

import com.whirled.TargetedSubControl;

/**
 * Dispatched either when somebody in this room entered our current game, or somebody playing the
 * game entered this room. On the client, the event is only dispatched if the player entering the
 * room is not the local player. On the server agent, it is always dispatched.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.PLAYER_ENTERED
 */
[Event(name="playerEntered", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched either when somebody in this room left our current game, or somebody playing the game
 * left this room. On the client, the event is only dispatched if the player leaving the room is not
 * the local player. On the server agent, it is always dispatched.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.PLAYER_LEFT
 */
[Event(name="playerLeft", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched when a player in this room takes up a new location. The event is dispatched
 * immediately when the move is initiated, not when the avatar arrives at the location. The movement
 * itself may take a potentially long time.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.PLAYER_MOVED
 */
[Event(name="playerMoved", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched when something has changed about a player's avatar in this room.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.AVATAR_CHANGED
 */
[Event(name="avatarChanged", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched when a MOB has been created.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.MOB_CONTROL_AVAILABLE
 * @see http://wiki.whirled.com/Mobs
 * @see RoomSubControlServer#spawnMob()
 */
[Event(name="mobControlAvailable", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched when a signal has been received in this room.
 *
 * @eventType com.whirled.avrg.AVRGameRoomEvent.SIGNAL_RECEIVED
 * @see com.whirled.EntityControl#sendSignal()
 */
[Event(name="signalReceived", type="com.whirled.avrg.AVRGameRoomEvent")]

/**
 * Dispatched when music starts playing in the room. If the current user can hear it,
 * id3 data *may* be available shortly after this event. The sequence of events goes like this:
 * MUSIC_STARTED, 0 or more MUSIC_ID3 tags (client only), MUSIC_STOPPED. Note however that
 * you may not get a MUSIC_STARTED event if the music starts playing prior to your avrg
 * being initialized. Calling getMusicOwnerId() can tell you definitively if there is music
 * currently playing.
 *
 * @eventType com.whirled.ControlEvent.MUSIC_STARTED
 */
[Event(name="musicStarted", type="com.whirled.ControlEvent")]

/**
 * Dispatched when music stops playing in the room. @see #event:MUSIC_STARTED
 *
 * @eventType com.whirled.ControlEvent.MUSIC_STOPPED
 */
[Event(name="musicStopped", type="com.whirled.ControlEvent")]

/**
 * Provides AVR services for a single room to clients and server agents.
 */
public class RoomSubControlBase extends TargetedSubControl
{
    /** @private */
    public function RoomSubControlBase (ctrl :AbstractControl, targetId :int)
    {
        super(ctrl, targetId);
    }

    /**
     * Gets the id of this room. Room ids are the same as scene ids and are the same each time the
     * room is visited. They may also be used directly to access a scene
     * (www.whirled.com/#world-s{sceneId}).
     */
    public function getRoomId () :int
    {
        // subclasses take care of this
        return 0;
    }

    /**
     * Returns the name of this room.
     */
    public function getRoomName () :String
    {
        return callHostCode("room_getRoomName_v1") as String;
    }

    /**
     * Gets an array of the ids of all the players in this room.
     * The players are a subset of the occupants.
     */
    public function getPlayerIds () :Array
    {
        return callHostCode("room_getPlayerIds_v1") as Array;
    }

    /**
     * Tests if a player of a given id is in this room.
     */
    public function isPlayerHere (id :int) :Boolean
    {
        return callHostCode("isPlayerHere_v1", id);
    }

    /**
     * Gets an array of the ids of all the occupants in this room.
     * The occupants is a superset of the players.
     */
    public function getOccupantIds () :Array
    {
        return callHostCode("room_getOccupantIds_v1") as Array;
    }

    /**
     * Get the name of the specified occupant, who may be a player, or null if not found.
     *
     * NOTE: names are not unique and can change at any time. You must use the playerId to
     * identify someone, and only retrieve the name for display purposes.
     */
    public function getOccupantName (playerId :int) :String
    {
        return callHostCode("room_getOccupantName_v1", playerId) as String;
    }

    /**
     * Get the playerId of the owner of the currently playing music, aka the player who added it
     * to the playlist, or 0 if there is no music currently playing.
     */
    public function getMusicOwnerId () :int
    {
        return callHostCode("getMusicOwner_v1");
    }

    /**
     * Returns an array of <code>String</code>s corresponding to the ids of all the MOBs in this
     * room.
     * @see http://wiki.whirled.com/Mobs
     */
    public function getSpawnedMobs () :Array
    {
        var mobIds :Array = [];
        for (var id :String in _mobControls) {
            mobIds.push(id);
        }
        return mobIds;
    }

    /**
     * Get the room's bounds in pixel coordinates. This is essentially the width and height
     * of the room's decor. It is an absolute coordinate system, i.e. (x, y) for one client
     * here is the same (x, y) as for another.
     *
     * @return a Rectangle anchored at (0, 0)
     */
    public function getRoomBounds () :Rectangle
    {
        return callHostCode("getRoomBounds_v1") as Rectangle;
    }

    /**
     * Gets all available information on the avatar of a player with the given id.
     * @throws Error if the player is not here
     */
    public function getAvatarInfo (playerId :int) :AVRGameAvatar
    {
        var data :Object = callHostCode("getAvatarInfo_v2", playerId);
        if (data == null) {
            return null;
        }
        var info :AVRGameAvatar = new AVRGameAvatar();
        info.entityId = data["entityId"];
        info.state = data["state"];
        info.x = data["x"];
        info.y = data["y"];
        info.z = data["z"];
        info.orientation = data["orientation"];
        info.moveSpeed = data["moveSpeed"];
        info.isMoving = data["isMoving"];
        info.isIdle = data["isIdle"];
        info.bounds = data["bounds"];
        return info;
    }

    /** @private */
    override public function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["musicStartStop_v1"] = musicStartStop_v1;
    }

    /** @private */
    internal function signalReceived_v1 (name :String, arg :Object) :void
    {
        dispatchEvent(
            new AVRGameRoomEvent(AVRGameRoomEvent.SIGNAL_RECEIVED, getRoomId(), name, arg));
    }

    /** @private */
    internal function playerLeft_v1 (id :int) :void
    {
        dispatchEvent(new AVRGameRoomEvent(AVRGameRoomEvent.PLAYER_LEFT, getRoomId(), null, id));
    }

    /** @private */
    internal function playerEntered_v1 (id :int) :void
    {
        dispatchEvent(new AVRGameRoomEvent(AVRGameRoomEvent.PLAYER_ENTERED, getRoomId(), null, id));
    }

    /** @private */
    internal function playerMoved_v1 (id :int) :void
    {
        dispatchEvent(new AVRGameRoomEvent(AVRGameRoomEvent.PLAYER_MOVED, getRoomId(), null, id));
    }

    /** @private */
    internal function actorAppearanceChanged_v1 (playerId :int) :void
    {
        dispatchEvent(new AVRGameRoomEvent(
            AVRGameRoomEvent.AVATAR_CHANGED, getRoomId(), null, playerId));
    }

    /** @private */
    internal function actorStateSet_v1 (playerId :int, state :String) :void
    {
        dispatchEvent(new AVRGameRoomEvent(
            AVRGameRoomEvent.AVATAR_CHANGED, getRoomId(), null, playerId));
    }

    /** @private */
    internal function setMobSubControl (
        mobId :String, ctrl :MobSubControlBase, delayEvent :Boolean) :void
    {
        if (_mobControls[mobId] !== undefined) {
            Log.getLog(this).warning("Eek, overwriting mob control [mobId=" + mobId + "]");
        }
        _mobControls[mobId] = ctrl;
        ctrl.gotHostProps(_funcs);
        var event :AVRGameRoomEvent = new AVRGameRoomEvent(
            AVRGameRoomEvent.MOB_CONTROL_AVAILABLE, getRoomId(), mobId, ctrl);
        if (delayEvent) {
            setTimeout(dispatchEvent, 0, event);
        } else {
            dispatchEvent(event);
        }
    }

    /** @private */
    internal function mobRemoved_v1 (id :String) :void
    {
        Log.getLog(this).debug("Nuking mob control [id=" + id + "]");
        delete _mobControls[id];
    }

    /** @private */
    internal function mobAppearanceChanged_v1 (
        mobId :String, locArray :Array, orient :Number,
        moving :Boolean, idle :Boolean) :void
    {
        var control :MobSubControlBase = _mobControls[mobId];
        if (control != null) {
            control.appearanceChanged(locArray, orient, moving, idle);
        }
    }

    /** @private */
    internal function musicStartStop_v1 (started :Boolean, ... rest) :void
    {
        dispatchEvent(new ControlEvent(
            started ? ControlEvent.MUSIC_STARTED : ControlEvent.MUSIC_STOPPED));
    }

    /** @private */
    protected var _mobControls :Dictionary = new Dictionary();
}
}

