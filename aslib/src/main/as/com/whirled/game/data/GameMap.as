//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import flash.utils.Dictionary;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.Streamable;

import com.threerings.util.Maps;
import com.threerings.util.maps.ForwardingMap;
import com.threerings.util.ObjectMarshaller;

public class GameMap extends ForwardingMap
    implements Streamable
{
    public function GameMap (dict :Dictionary = null)
    {
        super(Maps.newMapOf(int));
        if (dict != null) {
            populate(dict);
        }
    }

    /**
     * @throws Error if any keys are not ints.
     */
    public function populate (dict :Dictionary) :void
    {
        for (var key :Object in dict) {
            if (!(key is int)) {
                throw new Error("Dictionaries must only be populated with int keys.");
            }
            put(int(key), ObjectMarshaller.encode(dict[key]));
        }
    }

    /**
     * Convert back to a Dictionary.
     */
    public function toDictionary () :Dictionary
    {
        var dict :Dictionary = new Dictionary();
        forEach(function (key :int, value :Object) :void {
            dict[key] = ObjectMarshaller.decode(value);
        });
        return dict;
    }

    // from Streamable
    public function writeObject (out :ObjectOutputStream) :void
    {
        out.writeInt(size());
        forEach(function (key :int, value :Object) :void {
            out.writeInt(key);
            out.writeObject(value);
        });
    }

    // from Streamable
    public function readObject (ins :ObjectInputStream) :void
    {
        var size :int = ins.readInt();
        for (var ii :int = 0; ii < size; ii++) {
            put(ins.readInt(), ins.readObject());
        }
    }
}
}
