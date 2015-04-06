//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import flash.utils.ByteArray;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.presents.dobj.DSet_Entry;

/**
 * Represents a user's game-specific cookie data.
 */
public class UserCookie
    implements DSet_Entry
{
    /** The id of the player that has this cookie. */
    public var playerId :int;

    /** The cookie value. */
    public var cookie :ByteArray;

    public function UserCookie (playerId :int = 0, cookie :ByteArray = null)
    {
        this.playerId = playerId;
        this.cookie = cookie;
    }

    // from DSet_Entry
    public function getKey () :Object
    {
        return playerId;
    }

    // from superinterface Streamable
    public function readObject (ins :ObjectInputStream) :void
    {
        playerId = ins.readInt();
        cookie = (ins.readField(ByteArray) as ByteArray);
    }

    // from superinterface Streamable
    public function writeObject (out :ObjectOutputStream) :void
    {
        out.writeInt(playerId);
        out.writeField(cookie);
    }
}
}
