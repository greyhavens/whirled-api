//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

/**
 * Contains information on a trophy offered by this game.
 */
public class TrophyData extends GameData
{
    public function TrophyData ()
    {
        // nada
    }

    // from GameData
    override public function getType () :int
    {
        return TROPHY_DATA;
    }
}
}
