//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

/**
 * A special sprite for returning a Msoy thumbnail icon to usercode.
 */
public class Thumbnail extends Sprite
{
    public static const WIDTH :int = 80;
    public static const HEIGHT :int = 60;

    public function Thumbnail (thumb :DisplayObject = null)
    {
        if (thumb != null) {
            super.addChild(thumb);
        }
    }

    override public function get width () :Number
    {
        return WIDTH * scaleX;
    }

    override public function set width (newVal :Number) :void
    {
        scaleX = newVal / WIDTH;
    }

    override public function get height () :Number
    {
        return HEIGHT * scaleY;
    }

    override public function set height (newVal :Number) :void
    {
        scaleY = newVal / HEIGHT;
    }

    override public function addChild (child :DisplayObject) :DisplayObject
    {
        nope();
        return null;
    }

    override public function addChildAt (child :DisplayObject, index :int) :DisplayObject
    {
        nope();
        return null;
    }

    override public function contains (child :DisplayObject) :Boolean
    {
        return (child == this); // make it only work for us..
    }

    override public function getChildAt (index :int) :DisplayObject
    {
        return null;
    }

    override public function getChildByName (name :String) :DisplayObject
    {
        return null;
    }

    override public function getChildIndex (child :DisplayObject) :int
    {
        return -1;
    }

    override public function getObjectsUnderPoint (point :Point) :Array
    {
        return [];
    }

    override public function removeChild (child :DisplayObject) :DisplayObject
    {
        nope();
        return null;
    }

    override public function removeChildAt (index :int) :DisplayObject
    {
        nope();
        return null;
    }

    override public function setChildIndex (child :DisplayObject, index :int) :void
    {
        nope();
    }

    override public function swapChildren (child1 :DisplayObject, child2 :DisplayObject) :void
    {
        nope();
    }

    override public function swapChildrenAt (index1 :int, index2 :int) :void
    {
        nope();
    }

    protected function nope () :void
    {
        throw new Error("Operation not permitted.");
    }
}
}
