//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

/**
 * Contains information on a level pack available to this game.
 */
public class LevelData extends GameData
{
    /** Whether or not this pack is premium or free. */
    public boolean premium;

    // @Override // from GameData
    public byte getType ()
    {
        return LEVEL_DATA;
    }
}
