//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.parlor.game.data.GameConfig;

/**
 * Extends <code>MatchConfig</code> with information about match-making in the table style.
 */
public class TableMatchConfig extends MatchConfig
{
    /** The minimum number of seats at this table. */
    public var minSeats :int;

    /** The starting setting for the number of seats at this table. */
    public var startSeats :int;

    /** The maximum number of seats at this table. */
    public var maxSeats :int;

    /** This is set to true if this is a party game. */
    public var isPartyGame :Boolean;

    public function TableMatchConfig ()
    {
    }

    // from MatchConfig
    override public function getMatchType () :int
    {
        return isPartyGame ? GameConfig.PARTY : GameConfig.SEATED_GAME;
    }

    // from MatchConfig
    override public function getMinimumPlayers () :int
    {
        return minSeats;
    }

    // from MatchConfig
    override public function getMaximumPlayers () :int
    {
        return maxSeats;
    }

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        minSeats = ins.readInt();
        startSeats = ins.readInt();
        maxSeats = ins.readInt();
        isPartyGame = ins.readBoolean();
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(minSeats);
        out.writeInt(startSeats);
        out.writeInt(maxSeats);
        out.writeBoolean(isPartyGame);
    }
}
}
