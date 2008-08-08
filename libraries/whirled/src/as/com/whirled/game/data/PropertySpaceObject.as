//
// $Id$

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
}
}
