//
// $Id$

package com.whirled.game.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.whirled.game.data.PropertySpaceObject;

/**
 * Describes the property space functionality available to client that subscribe to 
 * an instance of {@link PropertySpaceObject}.
 */
public interface PropertySpaceService
    extends InvocationService
{
    /**
     * Sets a property on the target object.
     */
    void setProperty (Client caller, String propName, Object data, Integer key, boolean isArray, 
        boolean testAndSet, Object testValue, InvocationListener listener);
}
