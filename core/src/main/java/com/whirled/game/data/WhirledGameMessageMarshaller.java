//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

import javax.annotation.Generated;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;
import com.whirled.game.client.WhirledGameMessageService;

/**
 * Provides the implementation of the {@link WhirledGameMessageService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from WhirledGameMessageService.java.")
public class WhirledGameMessageMarshaller extends InvocationMarshaller
    implements WhirledGameMessageService
{
    /** The method id used to dispatch {@link #sendMessage} requests. */
    public static final int SEND_MESSAGE = 1;

    // from interface WhirledGameMessageService
    public void sendMessage (Client arg1, String arg2, Object arg3, InvocationService.InvocationListener arg4)
    {
        ListenerMarshaller listener4 = new ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(arg1, SEND_MESSAGE, new Object[] {
            arg2, arg3, listener4
        });
    }

    /** The method id used to dispatch {@link #sendPrivateMessage} requests. */
    public static final int SEND_PRIVATE_MESSAGE = 2;

    // from interface WhirledGameMessageService
    public void sendPrivateMessage (Client arg1, String arg2, Object arg3, int[] arg4, InvocationService.InvocationListener arg5)
    {
        ListenerMarshaller listener5 = new ListenerMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, SEND_PRIVATE_MESSAGE, new Object[] {
            arg2, arg3, arg4, listener5
        });
    }
}
