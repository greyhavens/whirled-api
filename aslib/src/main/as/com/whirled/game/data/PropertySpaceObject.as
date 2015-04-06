//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

/**
 * Any DObject can implement this interface if it wishes to export a PropertySpace to
 * the world, with the common operations implemented in {@link PropertySpaceHelper}.
 */
public interface PropertySpaceObject
{
    /**
     * Should return a pointer to the internal mapping of property names to property values.
     * This data structure will be modified by methods in {@link PropertySpaceHelper}.
     */
    function getUserProps () :Object;

    /**
     * Returns the marshaller for requesting a property change.
     */
    function getPropService () :PropertySpaceMarshaller;
}
}
