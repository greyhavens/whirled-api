//
// $Id$

package com.whirled.game.data;

import com.threerings.util.ActionScript;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.NamedEvent;

import com.whirled.game.server.PropertySpaceHelper;
import com.whirled.game.util.ObjectMarshaller;

/**
 * Represents a property change on the actionscript object we use in WhirledGameObject.
 */
@ActionScript(omit=true)
public class PropertySetEvent extends NamedEvent
{
    /** Suitable for unserialization. */
    public PropertySetEvent ()
    {
    }

    /**
     * Create a PropertySetEvent.
     */
    public PropertySetEvent (
        int targetOid, String propName, Object value, Integer key, boolean isArray, Object ovalue)
    {
        super(targetOid, propName);
        _data = value;
        _key = key;
        _isArray = isArray;
        _oldValue = ovalue;
    }

    /**
     * Returns the value that was set for the property.
     */
    public Object getValue ()
    {
        return _data;
    }

    /**
     * Returns the old value.
     */
    public Object getOldValue ()
    {
        return _oldValue;
    }

    /**
     * Returns the key, or null if not applicable.
     */
    public Integer getKey ()
    {
        return _key;
    }

    /**
     * Does the key apply to an array?
     */
    public boolean isArray ()
    {
        return _isArray;
    }

    // from abstract DEvent
    public boolean applyToObject (DObject target)
    {
        if (target instanceof PlaceObject && target instanceof PropertySpaceObject) {
            PropertySpaceObject psObj = (PropertySpaceObject) target;
            if (!PropertySpaceHelper.isOnServer(psObj)) {
                // TODO: this won't handle GameMaps
                _data = ObjectMarshaller.decode(_data);
            }
            if (_oldValue == UNSET_OLD_VALUE) {
                // only apply the property change if we haven't already
                try {
                    _oldValue = PropertySpaceHelper.applyPropertySet(
                        psObj, _name, _data, _key, _isArray);
                } catch (PropertySpaceObject.PropertySetException pse) {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    @Override
    protected void notifyListener (Object listener)
    {
        if (listener instanceof PropertySetListener) {
            ((PropertySetListener) listener).propertyWasSet(this);
        }
    }

    @Override @ActionScript(name="toStringBuf")
    protected void toString (StringBuilder buf)
    {
        buf.append("PropertySetEvent ");
        super.toString(buf);
        buf.append(", key=").append(_key);
    }

    /** The client-side data that is assigned to this property. */
    protected Object _data;

    /** The key of the property, if applicable. */
    protected Integer _key;

    /** True if the key applies to an array. */
    protected boolean _isArray;

    /** The old value. */
    protected transient Object _oldValue = UNSET_OLD_VALUE;
}
