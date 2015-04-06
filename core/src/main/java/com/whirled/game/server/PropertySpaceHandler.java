package com.whirled.game.server;

import static com.whirled.game.Log.log;

import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.server.InvocationException;
import com.whirled.game.data.PropertySetEvent;
import com.whirled.game.data.PropertySpaceObject;
import com.whirled.game.data.PropertySpaceObject.PropertySetException;

/**
 * Provides a property space service based on a {@link PropertySpaceObject}.
 * @see PropertySpaceHelper
 */
public abstract class PropertySpaceHandler
    implements PropertySpaceProvider
{
    /**
     * Creates a new handler for property spaces.
     */
    public PropertySpaceHandler (PropertySpaceObject props)
    {
        _props = props;
    }
    
    /**
     * Throws an {@link InvocationException} if the given caller cannot set a property. 
     */
    protected abstract void validateUser (ClientObject caller)
        throws InvocationException;

    // from PropertySpaceProvider
    public void setProperty (ClientObject caller, String propName, Object data, Integer key, 
        boolean isArray, boolean testAndSet, Object testValue, InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

        if (testAndSet && !PropertySpaceHelper.testProperty(_props, propName, testValue)) {
            return; // the test failed: do not set the property
        }
        setProperty(propName, data, key, isArray);
    }

    /**
     * Helper method to post a property set event.
     */
    protected void setProperty (String propName, Object value, Integer key, boolean isArray)
    {
        // apply the property set immediately
        try {
            Object oldValue = PropertySpaceHelper.applyPropertySet(
                _props, propName, value, key, isArray);
            if (_props instanceof DObject) {
                DObject dobj = (DObject)_props;
                dobj.postEvent(
                    new PropertySetEvent(dobj.getOid(), propName, value, key, isArray, oldValue));
            }
        } catch (PropertySetException pse) {
            log.info("Game attempted deprecated set semantics: " + pse.getMessage());
        }
    }

    protected PropertySpaceObject _props;
}
