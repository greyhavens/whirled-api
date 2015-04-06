//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game {

import flash.events.Event;

/**
 * Dispatched if the player closes the game lobby.
 */
public class LobbyClosedEvent extends Event
{
    /**
     * The type of this event.
     */
    public static const LOBBY_CLOSED :String = "LobbyClosed";

    /**
     * Constructor.
     */
    public function LobbyClosedEvent ()
    {
        super(LOBBY_CLOSED);
    }

    override public function toString () :String
    {
        return "[LobbyClosedEvent]";
    }

    override public function clone () :Event
    {
        return new LobbyClosedEvent();
    }
}
}
