//
// $Id$

package com.whirled.game.data;

import java.util.Map;
import java.util.Set;

import com.whirled.game.server.PropertySpaceHelper;

/**
 * Any DObject can implement this interface if it wishes to export a PropertySpace to
 * the world, with the common operations implemented in {@link PropertySpaceHelper}.
 */
public interface PropertySpaceObject
{
    /**
     * A checked exception thrown by applyPropertySet to indicate when
     * a property set failed for some reason. Usually this is caught on the server
     * and merely logged, but the information could be returned to the client.
     */
    public static class PropertySetException extends Exception
    {
        public PropertySetException (String msg, String propName, int key)
        {
            super(msg + " [prop=" + propName + ", key=" + key + "]");
        }
    }

    /**
     * Should return a pointer to the internal mapping of property names to property values.
     * This data structure will be modified by methods in {@link PropertySpaceHelper}.
     */
    Map<String, Object> getUserProps ();

    /**
     * Should return a pointer to the internal set of persistent properties that have been
     * written to since they were read at start-up.  This data structure will be modified by
     * methods in {@link PropertySpaceHelper} and is used to flush data to permanent store.
     */
    Set<String> getDirtyProps ();
}
