//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game {

import flash.events.Event;

/**
 * Dispatched when a player speaks.
 */
public class UserChatEvent extends Event
{
    /**
     * The type of a property change event.
     * @eventType UserChat
     */
    public static const USER_CHAT :String = "UserChat";

    /**
     * Get player id of the speaker.
     */
    public function get speaker () :int
    {
        return _speaker;
    }

    /**
     * Get the content of the chat.
     */
    public function get message () :String
    {
        return _message;
    }

    public function UserChatEvent (speaker :int, message :String)
    {
        super(USER_CHAT);
        _speaker = speaker;
        _message = message;
    }

    override public function toString () :String
    {
        return "[UserChatEvent speaker=" + _speaker + ", message=" + _message + "]";
    }

    override public function clone () :Event
    {
        return new UserChatEvent(_speaker, _message);
    }

    /** @private */
    protected var _speaker: int;

    /** @private */
    protected var _message :String;
}
}
