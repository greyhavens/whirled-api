//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.TargetedSubControl;
import com.whirled.net.PropertySubControl;

public class OfflinePlayerPropertyControl extends TargetedSubControl
    implements PropertySubControl
{
    public function OfflinePlayerPropertyControl (
        parent :AbstractControl, playerId :int, props :Object)
    {
        super(parent, playerId);

        _props = props;
    }

    /** @inheritDoc */
    public function get (propName :String) :Object
    {
        return _props[propName];
    }

    /** @inheritDoc */
    public function getPropertyNames (prefix :String = "") :Array
    {
        var props :Array = [];
        for (var s :String in _props) {
            if (s.lastIndexOf(prefix, 0) == 0) {
                props.push(s);
            }
        }
        return props;
    }

    /** @inheritDoc */
    public function set (propName :String, value :Object, immediate :Boolean = false) :void
    {
        callHostCode("setOfflinePlayerProperty_v1", propName, value, null, false, immediate);
    }

    /** @inheritDoc */
    public function setAt (
        propName :String, index :int, value :Object, immediate :Boolean = false) :void
    {
        callHostCode("setOfflinePlayerProperty_v1", propName, value, index, true, immediate);
    }

    /** @inheritDoc */
    public function setIn (
        propName :String, key :int, value :Object, immediate :Boolean = false) :void
    {
        callHostCode("setOfflinePlayerProperty_v1", propName, value, key, false, immediate);
    }

    protected var _props :Object;
}
}
