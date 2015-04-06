//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import com.threerings.util.Log;

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

/**
 * Dispatched when the location or orientation of a MOB changes.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.MOB_APPEARANCE_CHANGED
 */
[Event(name="mobAppearanceChanged", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Provides a means of accessing and controlling a previously spawned MOB.
 * @see http://wiki.whirled.com/Mobs
 * @see RoomSubControlServer#spawnMob()
 * @see RoomSubControlBase#event:mobControlAvailable
 */
public class MobSubControlBase extends AbstractSubControl
{
    /** @private */
    public function MobSubControlBase (parent :AbstractControl, id :String)
    {
        super(parent);
        _id = id;
    }

    /** @private */
    internal function appearanceChanged (
        location :Array, orient :Number, moving :Boolean, sleeping :Boolean) :void
    {
        _location = location;
        _orient = orient;
        _isMoving = moving;
        // "sleeping" is ignored in this class
        dispatchEvent(new AVRGameControlEvent(AVRGameControlEvent.MOB_APPEARANCE_CHANGED));
    }

    /** @private */
    protected var _id :String;

    /** Our current orientation, or 0. @private */
    protected var _orient :Number = 0;

    /** Indicates whether or not we're currently moving. @private */
    protected var _isMoving :Boolean;

    /** Contains our current location in the scene [x, y, z], or null. @private */
    protected var _location :Array;
}
}
