//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.io.TypedArray;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;
import com.whirled.game.client.WhirledGameMessageService;

/**
 * Provides the implementation of the <code>WhirledGameMessageService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class WhirledGameMessageMarshaller extends InvocationMarshaller
    implements WhirledGameMessageService
{
    /** The method id used to dispatch <code>sendMessage</code> requests. */
    public static const SEND_MESSAGE :int = 1;

    // from interface WhirledGameMessageService
    public function sendMessage (arg1 :String, arg2 :Object, arg3 :InvocationService_InvocationListener) :void
    {
        var listener3 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(SEND_MESSAGE, [
            arg1, arg2, listener3
        ]);
    }

    /** The method id used to dispatch <code>sendPrivateMessage</code> requests. */
    public static const SEND_PRIVATE_MESSAGE :int = 2;

    // from interface WhirledGameMessageService
    public function sendPrivateMessage (arg1 :String, arg2 :Object, arg3 :TypedArray /* of int */, arg4 :InvocationService_InvocationListener) :void
    {
        var listener4 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(SEND_PRIVATE_MESSAGE, [
            arg1, arg2, arg3, listener4
        ]);
    }
}
}
