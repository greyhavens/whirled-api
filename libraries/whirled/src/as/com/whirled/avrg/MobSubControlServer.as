//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;

/**
 * Defines actions, accessors and callbacks available to MOBs on the server.
 */
public class MobSubControlServer extends MobSubControlBase
{
    public function MobSubControlServer (parent :AbstractControl, id :String)
    {
        super(parent, id);
    }

    /**
     * Moves the mob to a new place in the room.
     */
    public function moveTo (x :Number, y :Number, z :Number) :void
    {
        RoomSubControlServer(_parent).callHostCodeFriend("moveMob_v1", _id, x, y, z);
    }
}
}