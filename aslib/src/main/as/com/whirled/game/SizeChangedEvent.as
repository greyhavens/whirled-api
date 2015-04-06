//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game {

import flash.events.Event;

import flash.geom.Point;

/**
 * Dispatched when the size of the game area changes, for example as a result of the user
 * resizing their browser window.
 */
public class SizeChangedEvent extends Event
{
    /**
     * The type of this event.
     *
     * @eventType SizeChanged
     */
    public static const SIZE_CHANGED :String = "SizeChanged";

    /**
     * Get the size of the game area, expressed as a Point
     * (The width is the x value, the height is the y value).
     */
    public function get size () :Point
    {
        return _size;
    }

    /**
     * Constructor.
     */
    public function SizeChangedEvent (size :Point)
    {
        super(SIZE_CHANGED);
        _size = size;
    }

    override public function toString () :String
    {
        return "[SizeChangedEvent size=" + _size + "]";
    }

    override public function clone () :Event
    {
        return new SizeChangedEvent(_size.clone()); // since _size is mutable
    }

    /** Our implementation details. @private */
    protected var _size: Point;
}
}
