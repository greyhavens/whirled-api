//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.net {

import flash.events.Event;

/**
 * An event dispatched when a single element is updated in an Array or Dictionary
 * property as a result of calling setAt() or setIn().
 */
public class ElementChangedEvent extends PropertyChangedEvent
{
    /**
     * The type of an ElementChangedEvent.
     *
     * @eventType ElemChanged
     */
    public static const ELEMENT_CHANGED :String = "ElemChanged";

    /**
     * Get the key (index) of the change.
     */
    public function get key () :int
    {
        return _key;
    }

    /**
     * Get the index (key) of the change.
     */
    public function get index () :int
    {
        return _key;
    }

    /**
     * Constructor.
     */
    public function ElementChangedEvent (
        type :String, propName :String, newValue :Object, oldValue :Object, key :int)
    {
        super(type, propName, newValue, oldValue);
        _key = key;
    }

    override public function toString () :String
    {
        return "[ElementChangedEvent name=" + _name + ", value=" + _newValue +
            ", key=" + _key + "]";
    }

    override public function clone () :Event
    {
        return new ElementChangedEvent(type, _name, _newValue, _oldValue, _key);
    }

    /** @private */
    protected var _key :int;
}
}
