//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.server;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;
import com.whirled.game.client.WhirledGameMessageService;

/**
 * Defines the server-side of the {@link WhirledGameMessageService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from WhirledGameMessageService.java.")
public interface WhirledGameMessageProvider extends InvocationProvider
{
    /**
     * Handles a {@link WhirledGameMessageService#sendMessage} request.
     */
    void sendMessage (ClientObject caller, String arg1, Object arg2, InvocationService.InvocationListener arg3)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameMessageService#sendPrivateMessage} request.
     */
    void sendPrivateMessage (ClientObject caller, String arg1, Object arg2, int[] arg3, InvocationService.InvocationListener arg4)
        throws InvocationException;
}
