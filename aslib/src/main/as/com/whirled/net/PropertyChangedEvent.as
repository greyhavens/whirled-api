//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.net {

import flash.events.Event;

/**
 * Property change events are dispatched after the property change was
 * validated on the server.
 */
public class PropertyChangedEvent extends Event
{
    /**
     * The type of a property change event.
     *
     * @eventType PropChanged
     */
    public static const PROPERTY_CHANGED :String = "PropChanged";

    /**
     * Get the name of the property that changed.
     */
    public function get name () :String
    {
        return _name;
    }

    /**
     * Get the property's new value.
     * Note: if index is not -1 then this value is merely one element in an array that
     * may be fully accessed using the 'net' subcontrol.
     */
    public function get newValue () :Object
    {
        return _newValue;
    }

    /**
     * Get the property's previous value (handy!).
     */
    public function get oldValue () :Object
    {
        return _oldValue;
    }

    /**
     * Constructor.
     */
    public function PropertyChangedEvent (
        type :String, propName :String, newValue :Object, oldValue :Object)
    {
        super(type);
        _name = propName;
        _newValue = newValue;
        _oldValue = oldValue;
    }

    override public function toString () :String
    {
        return "[PropertyChangedEvent name=" + _name + ", value=" + _newValue + "]";
    }

    override public function clone () :Event
    {
        return new PropertyChangedEvent(type, _name, _newValue, _oldValue);
    }

    /** @private */
    protected var _name :String;

    /** @private */
    protected var _newValue :Object;

    /** @private */
    protected var _oldValue :Object;
}
}
