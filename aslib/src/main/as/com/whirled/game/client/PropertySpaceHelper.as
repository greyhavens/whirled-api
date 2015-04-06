//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.utils.Dictionary;

import com.whirled.game.data.GameMap;
import com.whirled.game.data.PropertySpaceObject;

import com.threerings.io.ObjectInputStream;
import com.threerings.util.ObjectMarshaller;

public class PropertySpaceHelper
{
    /**
     * Utility to encode values.
     */
    public static function encodeProperty (value :Object, splitElements :Boolean) :Object
    {
        if (splitElements && (value is Dictionary)) {
            return new GameMap(value as Dictionary);
        }
        return ObjectMarshaller.encode(value, splitElements);
    }

    /**
     * Utility to decode values.
     */
    public static function decodeProperty (value :Object) :Object
    {
        if (value is GameMap) {
            return (value as GameMap).toDictionary();
        }
        return ObjectMarshaller.decode(value);
    }

    /**
     * Restores the state of the given {@link PropertySpaceObject} from the given stream. This
     * should be called from the custom serialization readObject(ObjectInputStream).
     */
    public static function readProperties (obj :PropertySpaceObject, ins :ObjectInputStream) :void
    {
        var props :Object = obj.getUserProps();

        var count :int = ins.readInt();
        while (count-- > 0) {
            var key :String = ins.readUTF();
            var value :Object = decodeProperty(ins.readObject());
            props[key] = value;
        }
    }

    /**
     * Called by a PropertySetEvent to enact a property change.
     * @return the old value
     *
     * @throws RangeError if the key is out of range (arrays only)
     */
    public static function applyPropertySet (
        obj :PropertySpaceObject, propName :String, value :Object,
        key :Object, isArray :Boolean) :Object
    {
        var props :Object = obj.getUserProps();

        var oldValue :Object = props[propName];
        if (key != null) {
            var index :int = int(key);
            if (isArray) {
                if (!(oldValue is Array)) {
                    throw new RangeError("Current value is not an Array.");
                }
                var arr :Array = (oldValue as Array);
                if (index < 0 || index >= arr.length) {
                    throw new RangeError("Array index out of range.");
                }
                oldValue = arr[index];
                arr[index] = value;

            } else {
                var dict :Dictionary = (oldValue as Dictionary);
                if (dict == null) {
                    dict = new Dictionary(); // force creation
                    props[propName] = dict;
                }
                oldValue = dict[index];
                if (value == null) {
                    delete dict[index];
                } else {
                    dict[index] = value;
                }
            }

        } else if (value != null) {
            // normal property set
            props[propName] = value;

        } else {
            // remove a property
            delete props[propName];
        }
        return oldValue;
    }
}
}
