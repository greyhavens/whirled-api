//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

/**
 * Contains metadata for a game add-on (level pack, item pack, trophy).
 */
public /*abstract*/ class GameData extends SimpleStreamableObject
{
    public static const RESOLUTION_MARKER :int = 0;

    public static const LEVEL_DATA :int = 1;

    public static const ITEM_DATA :int = 2;

    public static const TROPHY_DATA :int = 3;

    public static const PRIZE_MARKER :int = 4;

    /** A unique identifier for this pack. */
    public var ident :String;

    /** A human readable name for this pack. */
    public var name :String;

    /** The URL from which this pack's media can be downloaded. */
    public var mediaURL :String;

    public function GameData ()
    {
        // nada
    }

    /**
     * Returns the type of this game data object.
     */
    public /*abstract*/ function getType () :int
    {
        throw new Error("abstract getType() called");
    }

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        ident = (ins.readField(String) as String);
        name = (ins.readField(String) as String);
        mediaURL = (ins.readField(String) as String);
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(ident);
        out.writeField(name);
        out.writeField(mediaURL);
    }
}
}
