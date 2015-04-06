//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game {

import flash.events.Event;

/**
 * Dispatched when content-related events happen.
 */
public class GameContentEvent extends Event
{
    /**
     * Indicates that the a player has purchased new game content.
     * @eventType PlayerContentAdded
     */
    public static const PLAYER_CONTENT_ADDED :String = "PlayerContentAdded";

    /**
     * Indicates that the a player has consumed an item pack. contentType() for this event will
     * always be ITEM_PACK.
     * @eventType PlayerContentConsumed
     */
    public static const PLAYER_CONTENT_CONSUMED :String = "PlayerContentConsumed";

    /** Used to report item pack related events. */
    public static const ITEM_PACK :String = "item_pack";

    /** Used to report level pack related events. */
    public static const LEVEL_PACK :String = "level_pack";

    /**
     * Returns the type of content associated with this event. Either ITEM_PACK or LEVEL_PACK.
     */
    public function get contentType () :String
    {
        return _contentType;
    }

    /**
     * Returns the identifier of the content pack associated with this event.
     */
    public function get contentIdent () :String
    {
        return _contentIdent;
    }

    /**
     * Returns the identifier of the player to whom this event pertains or 0.
     */
    public function get playerId () :int
    {
        return _playerId;
    }

    public function GameContentEvent (
        type :String, contentType :String, contentIdent :String, playerId :int = 0)
    {
        super(type);
        _contentType = contentType;
        _contentIdent = contentIdent;
        _playerId = playerId;
    }

    override public function toString () :String
    {
        return "[GameContentEvent type=" + type + ", ctype=" + _contentType +
            ", cident=" + _contentIdent + ", pid=" + _playerId + "]";
    }

    override public function clone () :Event
    {
        return new GameContentEvent(type, _contentType, _contentIdent, _playerId);
    }

    protected var _contentType :String;
    protected var _contentIdent :String;
    protected var _playerId :int;
}
}
