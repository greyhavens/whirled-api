//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.crowd.data.OccupantInfo;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

public class WhirledGameOccupantInfo extends OccupantInfo
{
    /** False until the usercode has connected to the backend. */
    public var initialized :Boolean;

    public function WhirledGameOccupantInfo ()
    {
    }

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        initialized = ins.readBoolean();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeBoolean(initialized);
    }
}
}
