//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

/**
 * Calls a function when a property is set.
 */
public class PropertySetAdapter implements PropertySetListener
{
    /**
     * Creates a new adapter that calls the given function when a property is set.
     */
    public function PropertySetAdapter (changed :Function)
    {
        _changed = changed;
    }

    /** @inheritDoc */
    // from PropertySetListener
    public function propertyWasSet (event :PropertySetEvent) :void
    {
        _changed(event);
    }

    protected var _changed :Function;
}
}
