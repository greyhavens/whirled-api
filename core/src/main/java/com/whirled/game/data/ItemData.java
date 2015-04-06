//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

/**
 * Contains information on an item pack available to this game.
 */
public class ItemData extends GameData
{
    // @Override // from GameData
    public byte getType ()
    {
        return ITEM_DATA;
    }
}
