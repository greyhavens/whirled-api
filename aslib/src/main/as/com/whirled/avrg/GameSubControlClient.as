//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;

import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

/**
 * Provides AVR client game services.
 * @see AVRGameControl#game
 */
public class GameSubControlClient extends GameSubControlBase
{
    /** @private */
    public function GameSubControlClient (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    /**
     * Accesses the read-only properties associated with this game. To change properties use your
     * server agent's <code>GameSubControlServer</code>'s <code>props</code>.
     * @see GameSubControlServer#props
     */
    public function get props () :PropertyGetSubControl
    {
        return _props;
    }

    /** @private */
    override public function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["game_propertyWasSet_v1"] = _props.propertyWasSet_v1;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertyGetSubControlImpl(_parent, 0, "game_getGameData_v1");
        return [ _props ];
    }

    /** @private */
    protected var _props :PropertyGetSubControlImpl;
}
}
