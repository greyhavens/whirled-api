//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

/**
 * Superclass for controls that are instantiated in association with a specific
 * target, e.g. roomId or playerId. It centralizes the targetId member and sends
 * it automatically as the first argument to all backend functions.
 */
public class TargetedSubControl extends AbstractSubControl
{
    public function TargetedSubControl (parent :AbstractControl, targetId :int)
    {
        _targetId = targetId;

        super(parent);
    }

    /**
     * Get the targetId on which this control operates.
     */
    public function getTargetId () :int
    {
        return _targetId;
    }

    /** @private */
    override public function callHostCode (name :String, ... args) :*
    {
        args.unshift(name, _targetId);
        return super.callHostCode.apply(null, args);
    }

    /** @private */
    protected var _targetId :int;
}
}
