//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;

import flash.media.Camera;
import flash.media.Microphone;

import flash.utils.ByteArray;
import flash.utils.Timer;

/**
 * Dispatched when the instance in control sends a trigger action to all instances.
 *
 * @eventType com.whirled.ControlEvent.ACTION_TRIGGERED
 */
[Event(name="actionTriggered", type="com.whirled.ControlEvent")]

/**
 * Dispatched when any instance sends a message to all instances.
 *
 * @eventType com.whirled.ControlEvent.MESSAGE_RECEIVED
 */
[Event(name="messageReceived", type="com.whirled.ControlEvent")]

/**
 * Dispatched when any entity or AVR game sends a message to all other entities.
 * <p>Note: this is only dispatched to the instance in control.</p>
 *
 * @eventType com.whirled.ControlEvent.SIGNAL_RECEIVED
 * @see com.whirled.avrg.RoomSubControlServer#sendSignal()
 */
[Event(name="signalReceived", type="com.whirled.ControlEvent")]

/**
 * Dispatched when the instance in control updates the memory of this digital item.
 *
 * @eventType com.whirled.ControlEvent.MEMORY_CHANGED
 */
[Event(name="memoryChanged", type="com.whirled.ControlEvent")]

/**
 * Dispatched to entities when they overhear chatter in the room. Only
 * the instance in control receives this event.
 *
 * @eventType com.whirled.ControlEvent.CHAT_RECEIVED
 */
[Event(name="chatReceived", type="com.whirled.ControlEvent")]

/**
 * Dispatched when this instance gains control. See the <code>hasControl</code> method.
 *
 * @eventType com.whirled.ControlEvent.CONTROL_ACQUIRED
 */
[Event(name="controlAcquired", type="com.whirled.ControlEvent")]

/**
 * Dispatched once per tick, only when this instance has control and only if tick interval is
 * registered.
 *
 * @eventType flash.events.TimerEvent.TIMER
 */
[Event(name="timer", type="flash.events.TimerEvent")]

/**
 * Dispatched when an entity enters the room.
 *
 * @eventType com.whirled.ControlEvent.ENTITY_ENTERED
 */
[Event(name="entityEntered", type="com.whirled.ControlEvent")]

/**
 * Dispatched when an entity leaves the room.
 *
 * @eventType com.whirled.ControlEvent.ENTITY_LEFT
 */
[Event(name="entityLeft", type="com.whirled.ControlEvent")]

/**
 * Dispatched when an entity in the room (other than the listening entity) changes location.
 *
 * @eventType com.whirled.ControlEvent.ENTITY_MOVED
 */
[Event(name="entityMoved", type="com.whirled.ControlEvent")]

/**
 * Dispatched when music starts playing in the room. If the current user can hear it,
 * id3 data *may* be available shortly after this event. The sequence of events goes like this:
 * MUSIC_STARTED, 0 or more MUSIC_ID3 tags, MUSIC_STOPPED. Note however that you may not get
 * a MUSIC_STARTED event if the music starts playing prior to your entity initializing. Calling
 * getMusicOwnerId() can tell you definitively if there is music currently playing.
 *
 * @eventType com.whirled.ControlEvent.MUSIC_STARTED
 */
[Event(name="musicStarted", type="com.whirled.ControlEvent")]

/**
 * Dispatched when id3 data is found in the currently playing song. Apparently many mp3
 * files contain both 2.* id3 data, near the beginning of the file, and 1.* data, found at
 * the end, and so flash dispatches each set of data as it finds it. And we just pass
 * it along to you.
 *
 * @eventType com.whirled.ControlEvent.MUSIC_ID3
 */
[Event(name="musicId3", type="com.whirled.ControlEvent")]

/**
 * Dispatched when music stops playing in the room. @see #event:MUSIC_STARTED
 *
 * @eventType com.whirled.ControlEvent.MUSIC_STOPPED
 */
[Event(name="musicStopped", type="com.whirled.ControlEvent")]

/**
 * Handles services that are available to all entities in a room. This includes dispatching
 * trigger events and maintaining memory.
 */
public class EntityControl extends AbstractControl
{
    /** A constant returned by getEnvironment() to indicate that this entity is
     * being viewed in the "viewer": memories may be set and read, but they will not be saved. */
    public static const ENV_VIEWER :String = "viewer";

    /** A constant returned by getEnvironment() to indicate that this entity is
     * being viewed in the shop. If the user buys the item, any memories will be saved for
     * the user's new copy of the item. */
    public static const ENV_SHOP :String = "shop";

    /** A constant returned by getEnvironment() to indicate that this entity is
     * being viewed in a room. Memories are persistent. */
    public static const ENV_ROOM :String = "room";

    /** The type of furniture entities. */
    public static const TYPE_FURNI :String = "furni";

    /** The type of avatar entities. */
    public static const TYPE_AVATAR :String = "avatar";

    /** The type of pet entities. */
    public static const TYPE_PET :String = "pet";

    /**
     * The entity's location in logical coordinates (an Array [ x, y, z ]). x, y, and z are Numbers
     * between that are typically between 0 and 1 or null if our location is unknown.
     * Note that Whirled allows furniture to be positioned "outside" the room, at locations less
     * than 0 or greater than 1, in order to create a desired effect, so don't be surprised if
     * something is placed at wacky coordinates.
     * Use with getEntityProperty().
     */
    public static const PROP_LOCATION_LOGICAL :String = "std:location_logical";

    /**
     * The entity's location in pixel coordinates (an Array [ x, y, z ]). Obviously there is not a
     * real Z coordinate, but the value will coorrespond to real Z distance in proportion to the
     * distance in X and Y. Use with getEntityProperty().
     */
    public static const PROP_LOCATION_PIXEL :String = "std:location_pixel";

    /** The entity's hot spot (an Array [x, y]). Use with getEntityProperty(). */
    public static const PROP_HOTSPOT :String = "std:hotspot";

    /** The entity pixel dimensions (an Array [width, height]). Use with getEntityProperty(). */
    public static const PROP_DIMENSIONS :String = "std:dimensions";

    /**
     * The type of the entity, TYPE_AVATAR, TYPE_PET or TYPE_FURNI.
     * Use with getEntityProperty().
     */
    public static const PROP_TYPE :String = "std:type";

    /**
     * The entity facing direction (a Number). Use with getEntityProperty().
     * Valid only for "avatar" and "pet" entity types.
     */
    public static const PROP_ORIENTATION :String = "std:orientation";

    /**
     * The non-unique display name of the entity (a String). Use with getEntityProperty().
     * Valid only for "avatar" and "pet" entity types. Invalid entity types will return null.
     */
    public static const PROP_NAME :String = "std:name";

    /**
     * The unique Whirled player ID (int) of the wearer of the avatar, or the owner of the pet.
     * Use with getEntityProperty().
     */
    public static const PROP_MEMBER_ID :String = "std:member_id";

    /** The current movement speed of an actor (Number). */
    public static const PROP_MOVE_SPEED :String = "std:move_speed";

//    /** Whether or not the entity is moving (Boolean). Always false for non-actors. */
//    public static const PROP_IS_MOVING :String = "std:is_moving";

    /**
     * @private
     */
    public function EntityControl (disp :DisplayObject)
    {
        super(disp);

        if (Object(this).constructor == EntityControl) {
            throw new Error("Do not directly use EntityControl. " +
                "Use the appropriate subclass: AvatarControl, FurniControl, etc.");
        }
    }

    /**
     * Get the default datapack for this entity, or null if there is none defined.
     * The DataPack is returned as a ByteArray, which can easily be passed to the
     * com.whirled.DataPack constructor. We do not return a DataPack for you, because otherwise
     * including this class would include all the DataPack support classes, even if your
     * project never made use of it.
     */
    // TODO: better documentation, better name? (default is not the greatest)
    // TODO: Gawd, it'd be nice to be able to clear this once the user grabs it, so that
    // we don't have these bytes in memory as well as all the decoded info in the DataPack...
    public function getDefaultDataPack () :ByteArray
    {
        return _datapack;
    }

    /**
     * Get the "environment" in which this entity is presently running.
     *
     * @return one of the ENV_VIEWER, ENV_SHOP, or ENV_ROOM constants,
     * or null if we're not connected.
     */
    public function getEnvironment () :String
    {
        return _env;
    }

    /**
     * Returns our current logical location in the scene.  Note that if y is nonzero, you are
     * <b>flying</b>. If applicable, an avatar should animate appropriately. The actor method
     * <code>isMoving()</code> may return true or false when flying, depending on whether you're
     * floating or actually moving between locations.
     *
     * @return an array containing [ x, y, z ]. x, y, and z are Numbers between 0 and 1 or null if
     * our location is unknown.
     *
     * @see com.whirled.ActorControl#isMoving()
     */
    public function getLogicalLocation () :Array
    {
        return _location;
    }

    /**
     * Returns our current location in the scene, in pixel coordinates.
     *
     * @return an array containing [ x, y, z ] in pixel coordinates. Obviously there is not a
     * real Z coordinate, but the value will coorrespond to real Z distance in proportion
     * to the distance in X and Y.
     */
    public function getPixelLocation () :Array
    {
        if (_location == null) {
            return null;
        }
        var bounds :Array = getRoomBounds();
        for (var ii :int = 0; ii < _location.length; ii++) {
            bounds[ii] *= _location[ii];
        }
        return bounds;
    }

    /**
     * Get the room's bounds in pixels.
     *
     * @return an array containing [ width, height, depth ].
     */
    public function getRoomBounds () :Array
    {
        return callHostCode("getRoomBounds_v1") as Array;
    }

    /**
     * Returns true if the local client has management privileges in the current room.
     * A user with management permissions can edit the room, among other things.
     * Passing 0 for the memberId indicates that this instance's viewing user should be checked.
     * Note that this may change without notice, meaning that you shouldn't just check it once
     * for a user and assume they still have management permissions later.
     */
    public function canManageRoom (memberId :int = 0) :Boolean
    {
        return callHostCode("canEditRoom_v1", memberId) as Boolean;
    }

    /**
     * Triggers an action on this scene object. The action will be properly distributed to the
     * object running in every client in the scene, resulting in a ACTION_TRIGGERED event.
     *
     * <p>Note: the name must be a String and may be up to 64 characters. The argument may be up
     * to 1024 bytes after being AMF3 encoded.</p>
     *
     * <p>Note: Only the instance "in control" can trigger actions. If you want any instance to be
     * able to communicate, use <code>sendMessage()</code>.</p>
     */
    public function triggerAction (name :String, arg :Object = null) :void
    {
        callHostCode("sendMessage_v1", name, arg, true);
    }

    /**
     * Send a message to other instances of this entity, resulting in a MESSAGE_RECEIVED event.
     *
     * <p>Note: the name must be a String and may be up to 64 characters. The argument may be up
     * to 1024 bytes after being AMF3 encoded.</p>
     *
     * <p>Note: Any instance can send messages. Compare with triggerAction.</p>
     */
    public function sendMessage (name :String, arg :Object = null) :void
    {
        callHostCode("sendMessage_v1", name, arg, false);
    }

    /**
     * Send a message to all instances of all entities in this instance's current room,
     * resulting in a SIGNAL_RECEIVED event. All instances of the entity can initiate a
     * signal, so the user must take care to check for control when appropriate.
     *
     * <p>Note: the name must be a String and may be up to 64 characters. The argument may be up
     * to 1024 bytes after being AMF3 encoded.</p>
     */
    public function sendSignal (name :String, arg :Object = null) :void
    {
        callHostCode("sendSignal_v1", name, arg);
    }

    /**
     * Return an associative hash of all the memories. This is not a cheap operation. Use
     * <code>getMemory</code> if you know what you want.
     * @see #getMemory
     */
    public function getMemories () :Object
    {
        var mems :Object = callHostCode("getMemories_v1");
        // return an empty object if the host somereason returns null
        return (mems == null) ? {} : mems;
    }

    /**
     * Returns the value associated with the supplied key in this item's memory. If no value is
     * mapped in the item's memory, the supplied default value will be returned.
     *
     * @return the value for the specified key from this item's memory or the supplied default.
     */
    public function getMemory (key :String, defval :Object = null) :Object
    {
        var value :Object = callHostCode("lookupMemory_v1", key);
        return (value == null) ? defval : value;
    }

    /**
     * Requests that this item's memory be updated with the supplied key/value pair. The supplied
     * value must be a simple object (Integer, Number, String) or an Array of simple objects. The
     * contents of the entity's memory (keys and values) must not exceed 4096 bytes when AMF3
     * encoded.
     *
     * <p>Setting the memory for a key to null clears that key; subsequent lookups will return the
     * default value.</p>
     *
     * <p>Note: for avatars, only the instance "in control" can update memories, but this
     * restriction does not hold (presently) for pets, furni, toys, or backdrops. Put another
     * way, only the instance of the person wearing the avatar can update memories.</p>
     *
     * @param callback An optional function that is passed a Boolean indicating whether the
     * memory was successfully updated or not. True if the memory update was accepted, or false
     * if the memory update failed due to size or other restrictions.
     */
    public function setMemory (key :String, value :Object, callback :Function = null) :void
    {
        callHostCode("updateMemory_v1", key, value, callback);
    }

    /**
     * Get the id3 metadata of the currently playing music.
     * This will be an Object roughly in the format of flash.media.Id3Info, except
     * that only the "raw" names of id3 tags are supported.
     * http://www.id3.org
     */
    public function getMusicId3 () :Object
    {
        return callHostCode("getMusicId3_v1");
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
     * Enumerates the ids of all entities in this room.
     *
     * @param type an optional filter to restrict the results to a particular type of entity.
     */
    public function getEntityIds (type :String = null) :Array
    {
        var entities :Array = callHostCode("getEntityIds_v1", type);
        return (entities == null) ? [] : entities;
    }

    /**
     * Looks up and returns the specified property for the specified entity.
     * Returns null if the entity does not exist or the entity has no such property.
     */
    public function getEntityProperty (key :String, entityId :String = null) :Object
    {
        return callHostCode("getEntityProperty_v1", entityId, key);
    }

    /**
     * Returns the Whirled-wide unique ID of this copy of the entity. Multiple copies of the same
     * avatar in a room, for example, each have different entity IDs.
     */
    public function getMyEntityId () :String
    {
        return callHostCode("getMyEntityId_v1");
    }

    /**
     * Registers a function that provides custom entity properties. This should be done immediately
     * after creating your EntityControl, for example:
     *
     * <listing version="3.0">
     * var ctrl :FurniControl = new FurniControl(this);
     * ctrl.registerPropertyProvider(getEntityProperty);
     * </listing>
     *
     * @param func signature: function (key :String) :Object
     */
    public function registerPropertyProvider (func :Function) :void
    {
        _propertyProvider = func;
    }

    ///**
    // * Deletes this entity from the player's inventory and removed it from the room.
    // */
    //public function selfDestruct () :void
    //{
    //    callHostCode("selfDestruct_v1");
    //}

    /**
     * Detects whether this client is in control.
     *
     * <p>Control is a mutually exclusive lock across all instances of the entity (i.e. running in
     * other browsers across the network). Only one client can hold the lock at any time.</p>
     */
    public function hasControl () :Boolean
    {
        return _hasControl;
    }

    /**
     * Configures the interval on which this item is "ticked" in milliseconds. If the client
     * setting this interval is in control, it will get a <code>timer</code> event at the
     * specified interval.
     *
     * <p>Ticking mechanism is turned off by default. Application needs to set the interval
     * explicitly to start receiving tick events. The tick interval can be no smaller than 100ms
     * to avoid bogging down the client.</p>
     *
     * @param interval Delay between ticks in milliseconds, either 0ms, or a value larger
     * than 100ms. Value larger than zero activates the ticking mechanism,
     * and a value of exactly zero deactivates it.
     */
    public function setTickInterval (interval :Number) :void
    {
        _tickInterval = (interval > 100 || interval <= 0) ? interval : 100;

        if (_hasControl) {
            recheckTicker();
        }
    }

    /**
     * Get the id of the viewer that is viewing this instance.
     * An instance is the copy of the entity running in a particular user's browser.
     * If you are in a room with 2 other people, each piece of furniture has three instances:
     * one on each person's browser.
     *
     * @return the memberId of the player viewing this instance, or zero if the instance is being
     * viewed by something other than a player.
     */
    public function getInstanceId () :int
    {
        return int(callHostCode("getInstanceId_v1"));
    }

    /**
     * Get the non-unique display name of the user viewing a particular instance. Note
     * that this cannot be used to look up member names of people who are not in the room.
     *
     * <p>TODO: other examples of where the member id comes from.</p>
     *
     * @param id a memberId, for example one obtained from <code>getInstanceId</code>. If the
     * default argument of zero is passed, the instance id is used.
     *
     * @return a String or null if the viewer is unknown.
     */
    public function getViewerName (id :int = 0) :String
    {
        return callHostCode("getViewerName_v1", id) as String;
    }

    /**
     * Set the layout "hotspot" for your item, specified as pixels relative to (0, 0) the top-left
     * coordinate.
     *
     * If unset, the default hotspot will be based off of the SWF dimensions, with x = width / 2,
     * y = height.
     *
     * @param x the new hotspot x coordinate
     * @param y the new hotspot y coordinate
     * @param height if specified, the entity's actual current height, as pixels above the hotspot.
     *               This is used by avatars to position the name label.
     */
    public function setHotSpot (x :Number, y :Number, height :Number = NaN) :void
    {
        callHostCode("setHotSpot_v1", x, y, height);
    }

    /**
     * Show a popup to the current user in the whirled. Only one popup between all entities in
     * a room can be show at one time. Calling this closes any existing popup currently open.
     *
     * @param title The title displayed in the title bar for the popup.
     * @param panel The display object to show in the popup. It should only paint inside the
     *              rectangle defined by (0, 0, width, height).
     * @param width The width of the panel.
     * @param height The height of the panel.
     * @param backgroundColor The RGB value to fill the background of the panel with.
     * @param backgroundAlpha The transparency to fill the background of the panel with.
     *
     * @return true if the popup was shown, false if it could not be shown for various reasons.
     */
    public function showPopup (
        title :String, panel :DisplayObject, width :Number, height :Number,
        backgroundColor :uint = 0xFFFFFF, backgroundAlpha :Number = 1.0) :Boolean
    {
        return callHostCode("showPopup_v1", title, panel, width, height, backgroundColor,
                            backgroundAlpha) as Boolean;
    }

    /**
     * Clear any showing popup. May be called at any time.
     */
    public function clearPopup () :void
    {
        callHostCode("clearPopup_v1");
    }

    /**
     * Register a function used for generating a custom config panel. This will
     * be called when this piece of furniture is being edited inside whirled.
     *
     * @param func signature: function () :DisplayObject
     * <p>Your function should return a DisplayObject as a configuration panel.
     * The width/height of the object at return time will be used to configure the amount
     * of space given it. Any changes made by the user should effect immediately, or
     * you should provide buttons to apply the change, if absolutely necessary.</p>
     *
     */
    public function registerCustomConfig (func :Function) :void
    {
        _customConfig = func;
    }

    /**
     * Access the local user's camera.
     *
     * <p>Calling Camera.getCamera() does not work inside whirled due to security restrictions.
     * For convenience, this method works even when you're not connected.</p>
     */
    public function getCamera (index :String = null) :Camera
    {
        return isConnected() ? callHostCode("getCamera_v1", index) as Camera
                             : Camera.getCamera(index);
    }

    /**
     * Access the local user's microphone.
     *
     * <p>Calling Microphone.getMicrophone() does not work inside whirled due to security
     * restrictions. For convenience, this method works even when you're not connected.</p>
     */
    public function getMicrophone (index :int = -1) :Microphone
    {
        return isConnected() ? callHostCode("getMicrophone_v1", index) as Microphone
                             : Microphone.getMicrophone(index)
    }

    /**
     * Populate any properties that we provide back to whirled.
     * @private
     */
    override public function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["memoryChanged_v1"] = memoryChanged_v1;
        o["gotControl_v1"] = gotControl_v1;
        o["messageReceived_v1"] = messageReceived_v1;
        o["signalReceived_v1"] = signalReceived_v1;
        o["receivedChat_v2"] = receivedChat_v2;
        o["hasConfigPanel_v1"] = hasConfigPanel_v1;
        o["getConfigPanel_v1"] = getConfigPanel_v1;

        o["musicStartStop_v1"] = musicStartStop_v1;
        o["musicId3_v1"] = musicId3_v1;

        o["entityEntered_v1"] = entityEntered_v1;
        o["entityLeft_v1"] = entityLeft_v1;
        o["entityMoved_v2"] = entityMoved_v2;
        o["lookupEntityProperty_v1"] = lookupEntityProperty_v1;
    }

    /** @private */
    override public function gotHostProps (o :Object) :void
    {
        super.gotHostProps(o);

        if ("initProps" in o) {
            gotInitProps(o.initProps);
            delete o.initProps; // not needed after startup
        }
    }

    /** @private */
    override protected function checkIsConnected () :void
    {
        // Nothing. It's ok for entity code to attempt to call methods even when not connected.
    }

    /**
     * Entities get another packet of data called the initProps.
     *
     * @private
     */
    protected function gotInitProps (o :Object) :void
    {
        _location = (o["location"] as Array);
        _datapack = (o["datapack"] as ByteArray);
        _env = (o["env"] as String);
    }

    /**
     * WHIRLED INTERNAL.
     * Helper method to dispatch a ControlEvent, avoiding creation if there are no listeners.
     * @private
     */
    public function dispatchCtrlEvent (
        ctrlEvent :String, key :String = null, value :Object = null) :void
    {
        if (hasEventListener(ctrlEvent)) {
            dispatchEvent(new ControlEvent(ctrlEvent, key, value));
        }
    }

    /**
     * Called when an action or message is triggered on this scene object.
     * @private
     */
    protected function messageReceived_v1 (name :String, arg :Object, isAction :Boolean) :void
    {
        dispatchCtrlEvent(isAction ? ControlEvent.ACTION_TRIGGERED
                                   : ControlEvent.MESSAGE_RECEIVED, name, arg);
    }

    /**
     * Called when an action or message is triggered on this scene object.
     * @private
     */
    protected function signalReceived_v1 (name :String, arg :Object) :void
    {
        if (_hasControl) {
            dispatchCtrlEvent(ControlEvent.SIGNAL_RECEIVED, name, arg);
        }
    }

    /**
     * Called when one of this item's memory entries has changed.
     * @private
     */
    protected function memoryChanged_v1 (key :String, value :Object) :void
    {
        dispatchCtrlEvent(ControlEvent.MEMORY_CHANGED, key, value);
    }

    /** @private */
    protected function entityEntered_v1 (entityId :String) :void
    {
        if (_hasControl) {
            dispatchCtrlEvent(ControlEvent.ENTITY_ENTERED, entityId);
        }
    }

    /** @private */
    protected function entityLeft_v1 (entityId :String) :void
    {
        if (_hasControl) {
            dispatchCtrlEvent(ControlEvent.ENTITY_LEFT, entityId);
        }
    }

    /** @private */
    protected function entityMoved_v2 (entityId :String, destination :Array) :void
    {
        if (_hasControl) {
            dispatchCtrlEvent(ControlEvent.ENTITY_MOVED, entityId, destination);
        }
    }

    /**
     * Called when some other entity is requesting a property from this sprite.
     * @private
     */
    protected function lookupEntityProperty_v1 (key :String) :Object
    {
        return (_propertyProvider == null ? null : _propertyProvider(key));
    }

    /**
     * Called when this client has been assigned control of this object.
     * @private
     */
    protected function gotControl_v1 () :void
    {
        if (_hasControl) {
            return; // avoid re-dispatching
        }
        _hasControl = true;

        // dispatch to user code..
        dispatchCtrlEvent(ControlEvent.CONTROL_ACQUIRED);

        // possibly set up a ticker now
        recheckTicker();
    }

    /**
     * @private
     */
    protected function hasConfigPanel_v1 () :Boolean
    {
        return (_customConfig != null); // we assume it'll work...
    }

    /**
     * Called when whirled is editing this furniture, to retrieve any custom configuration
     * panel.
     * @private
     */
    protected function getConfigPanel_v1 () :DisplayObject
    {
        // TODO: make this dispatch an event that receives the config in a method
        return (_customConfig != null) ? (_customConfig() as DisplayObject) : null;
    }

    /**
     * Called when this entity is overhearing a line of chatter in the room.
     * If this instance of the entity has control, it will dispatch a new receivedChat event,
     * otherwise the line will be ignored.
     * @private
     */
    protected function receivedChat_v2 (entityId :String, message :String) :void
    {
        if (_hasControl) {
            dispatchCtrlEvent(ControlEvent.CHAT_RECEIVED, entityId, message);
        }
    }

    /** @private */
    protected function musicStartStop_v1 (started :Boolean, ... rest) :void
    {
        dispatchCtrlEvent(started ? ControlEvent.MUSIC_STARTED : ControlEvent.MUSIC_STOPPED);
    }

    /** @private */
    protected function musicId3_v1 (id3 :Object) :void
    {
        dispatchCtrlEvent(ControlEvent.MUSIC_ID3, null, id3);
    }

    /**
     * Check the status of the ticker, starting or stopping it as necessary.
     * @private
     */
    protected function recheckTicker () :void
    {
        if (_hasControl && _tickInterval > 0) {
            if (_ticker == null) {
                // we may be creating the timer for the first time
                _ticker = new Timer(_tickInterval);
                // re-route it
                _ticker.addEventListener(TimerEvent.TIMER, dispatchEvent);

            } else {
                // we may just be committing a new interval
                _ticker.delay = _tickInterval;
            }
            _ticker.start(); // start if not already running

        } else {
            stopTicker();
        }
    }

    /**
     * Stops our AI ticker.
     * @private
     */
    protected function stopTicker () :void
    {
        if (_ticker != null) {
            _ticker.stop();
            _ticker = null;
        }
    }

    /**
     * @private
     */
    override protected function handleUnload (evt :Event) :void
    {
        super.handleUnload(evt);

        _hasControl = false;
        stopTicker();
    }

    /** Contains our current location in the scene [x, y, z], or null. @private */
    protected var _location :Array;

    /** Our desired tick interval (in milliseconds). @private */
    protected var _tickInterval :Number = 0;

    /** Used to tick this object when this client is running its AI. @private */
    protected var _ticker :Timer;

    /** Whether this instance has control. @private */
    protected var _hasControl :Boolean = false;

    /** The environment in which we're running. */
    protected var _env :String;

    /** A function registered to return a custom configuration panel. @private */
    protected var _customConfig :Function;

    /** The default datapack, if any. @private */
    protected var _datapack :ByteArray;

    /** User specified callback to publish properties. @private */
    protected var _propertyProvider :Function;
}
}
