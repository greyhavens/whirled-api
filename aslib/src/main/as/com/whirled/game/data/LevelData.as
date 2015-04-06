//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

/**
 * Contains information on an item pack available to this game.
 */
public class LevelData extends GameData
{
    /** Whether or not this pack is premium or free. */
    public var premium :Boolean;

    public function LevelData ()
    {
        // nada
    }

    // from GameData
    override public function getType () :int
    {
        return LEVEL_DATA;
    }

    // from SimpleStreamableObject
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        premium = ins.readBoolean();
    }

    // from SimpleStreamableObject
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeBoolean(premium);
    }
}
}
