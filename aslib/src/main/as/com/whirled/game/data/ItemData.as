//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

/**
 * Contains information on an item pack available to this game.
 */
public class ItemData extends GameData
{
    public function ItemData ()
    {
        // nada
    }

    // from GameData
    override public function getType () :int
    {
        return ITEM_DATA;
    }
}
}
