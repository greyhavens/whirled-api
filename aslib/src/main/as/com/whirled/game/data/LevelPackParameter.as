//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

/**
 * A file parameter for representing downloadable content packs on the test server.
 */
public class LevelPackParameter extends ContentPackParameter
{
    /** Is the level pack premium? */
    public var premium :Boolean;

    public function LevelPackParameter ()
    {
    }

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        premium = (ins.readField(Boolean) as Boolean);
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(premium);
    }
}
}
