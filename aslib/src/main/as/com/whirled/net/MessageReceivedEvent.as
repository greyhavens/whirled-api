//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.net {

import flash.events.Event;

/**
 * Dispatched on the 'net' subcontrol when a message is sent by any client.
 */
public class MessageReceivedEvent extends Event
{
    /**
     * The type of all MessageReceivedEvents.
     *
     * @eventType MsgReceived
     */
    public static const MESSAGE_RECEIVED :String = "MsgReceived";

    /**
     * Access the message name.
     */
    public function get name () :String
    {
        return _name;
    }

    /**
     * Access the message value.
     */
    public function get value () :Object
    {
        return _value;
    }

    /**
     * Access the id of the occupant that sent the message. The value may not correspond to a real 
     * occupant id if <code>isFromServer</code> returns true.
     * @see #isFromServer()
     */
    public function get senderId () :int
    {
        return _senderId;
    }

    /**
     * Returns true if the message was sent by the whirled game server or by the game's server 
     * agent.
     */
    public function isFromServer () :Boolean
    {
        return _senderId == SERVER_ID || _senderId == SERVER_AGENT_ID;
    }

    public function MessageReceivedEvent (messageName :String, value :Object, senderId :int)
    {
        super(MESSAGE_RECEIVED);
        _name = messageName;
        _value = value;
        _senderId = senderId;
    }

    override public function toString () :String
    {
        return "[MessageReceivedEvent name=" + _name + ", value=" + _value +
            ", sender=" + _senderId + "]";
    }

    override public function clone () :Event
    {
        return new MessageReceivedEvent(_name, _value, _senderId);
    }

    /** @private */
    protected var _name :String;

    /** @private */
    protected var _value :Object;

    /** @private */
    protected var _senderId :int;

    /** 
     * Sender id indicating that the message is from the whirled game server.
     * TODO: does this need to be public?
     */
    protected static const SERVER_ID :int = 0;

    /** 
     * Sender id indicating that the message is from the game's server agent. 
     * TODO: does this need to be public?
     */
    protected static const SERVER_AGENT_ID :int = int.MIN_VALUE;
}
}
