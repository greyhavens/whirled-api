//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.server;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationDispatcher;
import com.threerings.presents.server.InvocationException;
import com.whirled.game.data.WhirledGameMessageMarshaller;

/**
 * Dispatches requests to the {@link WhirledGameMessageProvider}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from WhirledGameMessageService.java.")
public class WhirledGameMessageDispatcher extends InvocationDispatcher<WhirledGameMessageMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public WhirledGameMessageDispatcher (WhirledGameMessageProvider provider)
    {
        this.provider = provider;
    }

    @Override
    public WhirledGameMessageMarshaller createMarshaller ()
    {
        return new WhirledGameMessageMarshaller();
    }

    @Override
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case WhirledGameMessageMarshaller.SEND_MESSAGE:
            ((WhirledGameMessageProvider)provider).sendMessage(
                source, (String)args[0], args[1], (InvocationService.InvocationListener)args[2]
            );
            return;

        case WhirledGameMessageMarshaller.SEND_PRIVATE_MESSAGE:
            ((WhirledGameMessageProvider)provider).sendPrivateMessage(
                source, (String)args[0], args[1], (int[])args[2], (InvocationService.InvocationListener)args[3]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
