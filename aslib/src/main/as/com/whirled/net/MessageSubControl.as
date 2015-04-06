//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.net {

/**
 * Provides message passing functionality to a set of listener(s), e.g. other clients
 * and/or the server agent, if one is employed.
 */
public interface MessageSubControl
{
    /**
     * Send a "message" to the listener(s) associated with this control. If the recipient is
     * listening for messages, they can react to it. This is similar to setting a property,
     * except the value is not automatically saved -- it will just be sent along with the
     * message.
     *
     * @param messageName The message to send.
     * @param value The value to attach to the message.
     */
    function sendMessage (name :String, value :Object = null) :void
}
}
