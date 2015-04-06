//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.net.impl {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

import com.whirled.TargetedSubControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.PropertyChangedEvent;

public class PropertyGetSubControlImpl extends TargetedSubControl
    implements PropertyGetSubControl
{
    public function PropertyGetSubControlImpl (
        ctrl :AbstractControl, targetId :int, fn_getGameData :String)
    {
        _fn_getGameData = fn_getGameData;
        super(ctrl, targetId);
    }

    /** @inheritDoc */
    public function get (propName :String) :Object
    {
        return callHostCode(_fn_getGameData)[propName];
    }

    /** @inheritDoc */
    public function getPropertyNames (prefix :String = "") :Array
    {
        var props :Array = [];
        for (var s :String in callHostCode(_fn_getGameData)) {
            if (s.lastIndexOf(prefix, 0) == 0) {
                props.push(s);
            }
        }
        return props;
    }

    /**
     * Internal method to post a PropertyChangedEvent. Called from various subcontrols.
     * @private
     */
    public function propertyWasSet_v1 (
        name :String, newValue :Object, oldValue :Object, key :Object) :void
    {
        if (key == null) {
            dispatchEvent(new PropertyChangedEvent(
                PropertyChangedEvent.PROPERTY_CHANGED, name, newValue, oldValue));
        } else {
            dispatchEvent(new ElementChangedEvent(
                ElementChangedEvent.ELEMENT_CHANGED, name, newValue, oldValue, int(key)));
        }
    }

    /** @private */
    protected var _fn_getGameData :String;
}
}
