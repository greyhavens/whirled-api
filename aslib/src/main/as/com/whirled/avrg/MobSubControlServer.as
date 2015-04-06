//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;

/**
 * Provides the server agent with a means of controlling a previously spawned MOB.
 * @see AVRServerGameControl#spawnMob()
 * @see RoomSubControlBase#event:mobControlAvailable
 * @see RoomSubControlServer#getMobSubControl()
 * @see http://wiki.whirled.com/Mobs
 */
public class MobSubControlServer extends MobSubControlBase
{
    /** @private */
    public function MobSubControlServer (parent :AbstractControl, id :String)
    {
        super(parent, id);
    }

    /**
     * Moves the mob to a new place in room coordinates.
     * @see http://wiki.whirled.com/Coordinate_systems
     * @see MobSubControlBase#event:mobAppearanceChanged
     */
    public function moveTo (x :Number, y :Number, z :Number) :void
    {
        RoomSubControlServer(_parent).callHostCode("moveMob_v1", _id, x, y, z);
    }
}
}
