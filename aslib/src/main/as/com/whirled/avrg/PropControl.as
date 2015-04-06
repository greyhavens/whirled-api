//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import flash.display.DisplayObject;

import com.whirled.FurniControl;

/**
 * Defines actions, accessors and callbacks available to all Props.
 */
public class PropControl extends FurniControl
{
    /**
     * Creates a controller for a Prop. The display object is the Prop's visualization.
     */
    public function PropControl (disp :DisplayObject)
    {
        super(disp);
    }

    // TODO: document
    public function isGameActivated () :Boolean
    {
        return callHostCode("isGameActivated_v1") as Boolean;
    }

    // TODO: document
    public function activateGame () :Boolean
    {
        return callHostCode("activateGame_v1") as Boolean;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
        ];
    }
}
}
