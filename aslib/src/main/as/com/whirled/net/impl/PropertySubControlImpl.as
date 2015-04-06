//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.net.impl {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.net.PropertySubControl;

public class PropertySubControlImpl extends PropertyGetSubControlImpl
    implements PropertySubControl
{
    public function PropertySubControlImpl (
        ctrl :AbstractControl, targetId :int, fn_getGameData :String, fn_setProperty :String)
    {
        _fn_setProperty = fn_setProperty;
        super(ctrl, targetId, fn_getGameData);
    }

    /** @inheritDoc */
    public function set (propName :String, value :Object, immediate :Boolean = false) :void
    {
        callHostCode(_fn_setProperty, propName, value, null, false, immediate);
    }

    /** @inheritDoc */
    public function setAt (
        propName :String, index :int, value :Object, immediate :Boolean = false) :void
    {
        callHostCode(_fn_setProperty, propName, value, index, true, immediate);
    }

    /** @inheritDoc */
    public function setIn (
        propName :String, key :int, value :Object, immediate :Boolean = false) :void
    {
        callHostCode(_fn_setProperty, propName, value, key, false, immediate);
    }

    /** @private */
    protected var _fn_setProperty :String;
}
}
