//
// $Id$

package com.whirled.game.data {

import flash.utils.ByteArray;
import flash.utils.IExternalizable;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.Streamer;

import com.threerings.util.Integer;
import com.threerings.util.ObjectMarshaller;
import com.threerings.util.StringBuilder;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.NamedEvent;

import com.whirled.game.client.PropertySpaceHelper;

/**
 * Represents a property change on the actionscript object we use in PropertySpaceObjects.
 */
public class PropertySetEvent extends NamedEvent
{
    /**
     * Create a PropertySetEvent.
     */
    public function PropertySetEvent () // unserialize-only
    {
        super(0, null);
    }

    // from abstract DEvent
    override public function applyToObject (target :DObject) :Boolean
    {
        try {
            _oldValue = PropertySpaceHelper.applyPropertySet(
                PropertySpaceObject(target), _name, _data, _key, _isArray);
        } catch (re :RangeError) {
            trace("Error setting property: " + re);
            return false;
        }
        return true;
    }

    /**
     * Get the value that was set for the property.
     */
    public function getValue () :Object
    {
        return _data;
    }

    /**
     * Get the key, or null if not applicable.
     */
    public function getKey () :Integer
    {
        return _key;
    }

    /**
     * Does the key apply to an array?
     */
    public function isArray () :Boolean
    {
        return _isArray;
    }

    /**
     * Get the old value.
     */
    public function getOldValue () :Object
    {
        return _oldValue;
    }

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _data = PropertySpaceHelper.decodeProperty(ins.readObject());
        _key = ins.readField(Integer) as Integer;
        _isArray = ins.readBoolean();
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_data);
        out.writeField(_key);
        out.writeBoolean(_isArray);
    }

    override protected function notifyListener (listener :Object) :void
    {
        if (listener is PropertySetListener) {
            (listener as PropertySetListener).propertyWasSet(this);
        }
    }

    override protected function toStringBuf (buf :StringBuilder) :void
    {
        buf.append("PropertySetEvent ");
        super.toStringBuf(buf);
        buf.append(", key=").append(_key).append(", isArray=").append(_isArray);
    }

    /** The client-side data that is assigned to this property. */
    protected var _data :Object;

    /** The key of the property, if applicable. */
    protected var _key :Integer;

    /** True if the key applies to an array. */
    protected var _isArray :Boolean;

    /** The old value. */
    protected var _oldValue :Object;
}
}
