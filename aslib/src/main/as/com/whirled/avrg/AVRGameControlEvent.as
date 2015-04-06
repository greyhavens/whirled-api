//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import flash.events.Event;

/**
 * Conveys information about a change to the state of an AVR game.
 */
public class AVRGameControlEvent extends Event
{
    /**
     * An event type dispatched when somebody joined the AVRG.
     * <br/><b>name</b> - not used
     * <br/><b>value :int</b> - the id of the player who has joined
     *
     * @eventType playerJoinedGame
     * @see GameSubControlServer
     */
    public static const PLAYER_JOINED_GAME :String = "playerJoinedGame";

    /**
     * An event type dispatched when somebody is leaving the AVRG.
     * <br/><b>name</b> - not used
     * <br/><b>value :int</b> - the memberId of the player
     *
     * @eventType playerQuitGame
     * @see GameSubControlServer
     */
    public static const PLAYER_QUIT_GAME :String = "playerQuitGame";

    /**
     * An event type dispatched when the control has been resized.
     * <br/><b>name</b> - not used
     * <br/><b>value</b> - not used
     *
     * @eventType sizeChanged
     * @see LocalSubControl
     * @see LocalSubControl#getPaintableArea()
     */
    public static const SIZE_CHANGED :String = "sizeChanged";

    /**
     * An event type dispatched when a spawned MOB has changed appearance.
     * <br/><b>name</b> - not used
     * <br/><b>value</b> - not used
     *
     * @eventType mobAppearanceChanged
     * @see MobSubControlClient
     * @see MobSubControlServer
     */
    public static const MOB_APPEARANCE_CHANGED :String = "mobAppearanceChanged";

    /**
     * Retrieves the 'name' for this event, which is a String value
     * whose meaning is determined by the event type.
     */
    public function get name () :String
    {
        return _name;
    }

    /**
     * Retrieves the object 'value' for this event, which is a value
     * whose meaning is determined by the event type.
     */
    public function get value () :Object
    {
        return _value;
    }

    /**
     * Creates a new AVRGameControlEvent.
     */
    public function AVRGameControlEvent (
        type :String, name :String = null, value :Object = null, cancelable :Boolean = false)
    {
        super(type, false, cancelable);

        _name = name;
        _value = value;
    }

    /** @inheritDoc */
    // from Event
    override public function toString () :String
    {
        return "AVRGameControlEvent [type=" + type + ", name=" + _name + ", value=" + _value +
            ", cancelable=" + cancelable + "]";
    }

    /** @inheritDoc */
    // documentation inherited from Event
    override public function clone () :Event
    {
        return new AVRGameControlEvent(type, _name, _value, cancelable);
    }

    /** Internal storage for our name property. @private */
    protected var _name :String;

    /** Internal storage for our value property. @private */
    protected var _value :Object;
}
}
