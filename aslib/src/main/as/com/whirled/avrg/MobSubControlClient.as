//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import flash.display.DisplayObject;

import com.threerings.util.Log;

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

/**
 * Provides clients with a means of accessing and controlling a previously spawned MOB.
 * @see http://wiki.whirled.com/Mobs
 * @see RoomSubControlServer#spawnMob()
 * @see RoomSubControlBase#event:mobControlAvailable
 * @see RoomSubControlClient#getMobSubControl()
 */
public class MobSubControlClient extends MobSubControlBase
{
    /** @private */
    public function MobSubControlClient (parent :AbstractControl, id :String, sprite :DisplayObject)
    {
        super(parent, id);
        _sprite = sprite;
    }

    /**
     * Accesses the sprite object for this MOB. If non-null, this will return the value created by
     * the mob sprite exporter assigned in the <code>LocalSubControl</code>.
     * @see LocalSubControl#setMobSpriteExporter()
     */
    public function getMobSprite () :DisplayObject
    {
        return _sprite;
    }

    /**
     * Set the layout "hotspot" for your item, specified as pixels relative to (0, 0) the top-left
     * coordinate.
     *
     * If unset, the default hotspot will be based off of the SWF dimensions, with x = width / 2,
     * y = height.
     */
    public function setHotSpot (x :Number, y :Number, height :Number = NaN) :void
    {
        callHostCode("setMobHotSpot_v1", _id, x, y, height);
    }

    /**
     * Assigns an object to decorate a mob.
     */
    // TODO: need to mention where the object will appear
    public function setDecoration (decoration :DisplayObject) :void
    {
        if (_decoration == null) {
            _decoration = decoration;
            callHostCode("setMobDecoration_v1", _id, _decoration, true);
        }
    }

    /**
     * Removes the previously assigned decoration.
     */
    public function removeDecoration () :void
    {
        if (_decoration != null) {
            var oldDec :DisplayObject = _decoration;
            _decoration = null;
            callHostCode("setMobDecoration_v1", _id, oldDec, false);
        }
    }

    /** @private */
    protected var _sprite :DisplayObject;

    /** @private */
    protected var _decoration :DisplayObject;
}
}
