//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

import javax.annotation.Generated;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;
import com.whirled.game.client.PropertySpaceService;

/**
 * Provides the implementation of the {@link PropertySpaceService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PropertySpaceService.java.")
public class PropertySpaceMarshaller extends InvocationMarshaller
    implements PropertySpaceService
{
    /** The method id used to dispatch {@link #setProperty} requests. */
    public static final int SET_PROPERTY = 1;

    // from interface PropertySpaceService
    public void setProperty (Client arg1, String arg2, Object arg3, Integer arg4, boolean arg5, boolean arg6, Object arg7, InvocationService.InvocationListener arg8)
    {
        ListenerMarshaller listener8 = new ListenerMarshaller();
        listener8.listener = arg8;
        sendRequest(arg1, SET_PROPERTY, new Object[] {
            arg2, arg3, arg4, Boolean.valueOf(arg5), Boolean.valueOf(arg6), arg7, listener8
        });
    }
}
