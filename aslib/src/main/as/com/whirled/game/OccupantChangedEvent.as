//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game {

import flash.events.Event;

/**
 * Dispatched when an occupant enters or leaves.
 *
 * If a watcher becomes a player, you may get an OCCUPANT_LEFT event where player == false,
 * followed immediately by an OCCUPANT_ENTERED event where player == true.
 */
public class OccupantChangedEvent extends Event
{
    /**
     * @eventType OccupantEntered
     */
    public static const OCCUPANT_ENTERED :String = "OccupantEntered";

    /**
     * @eventType OccupantLeft
     */
    public static const OCCUPANT_LEFT :String = "OccupantLeft";

    /** The occupantId of the occupant that entered or left. */
    public function get occupantId () :int
    {
        return _occupantId;
    }

    /** Is/was the occupant a player? If false, they are/were a watcher. */
    public function get player () :Boolean
    {
        return _player;
    }

    public function OccupantChangedEvent (type :String, occupantId :int, player :Boolean)
    {
        super(type);
        _occupantId = occupantId;
        _player = player;
    }

    override public function toString () :String
    {
        return "[OccupantChangedEvent type=" + type +
            ", occupantId=" + _occupantId +
            ", player=" + _player + "]";
    }

    override public function clone () :Event
    {
        return new OccupantChangedEvent(type, _occupantId, _player);
    }

    /** @private */
    protected var _occupantId :int;

    /** @private */
    protected var _player :Boolean;
}
}
