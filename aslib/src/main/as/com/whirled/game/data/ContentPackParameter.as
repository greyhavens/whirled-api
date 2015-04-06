//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.parlor.data.Parameter;

/**
 * A file parameter for representing downloadable content packs on the test server.
 */
public class ContentPackParameter extends Parameter
{
    /** URL to the content pack on the test server. */
    public var mediaURL :String;

    public function ContentPackParameter ()
    {
    }

    // from Parameter
    override public function getLabel () :String
    {
        return "[content pack '" + ident + "']";
    }

    // from Parameter
    override public function getDefaultValue () :Object
    {
        return new Object();
    }

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        mediaURL = (ins.readField(String) as String);
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(mediaURL);
    }
}
}
