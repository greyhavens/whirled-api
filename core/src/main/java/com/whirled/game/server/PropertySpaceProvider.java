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
import com.whirled.game.client.PropertySpaceService;

/**
 * Defines the server-side of the {@link PropertySpaceService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PropertySpaceService.java.")
public interface PropertySpaceProvider extends InvocationProvider
{
    /**
     * Handles a {@link PropertySpaceService#setProperty} request.
     */
    void setProperty (ClientObject caller, String arg1, Object arg2, Integer arg3, boolean arg4, boolean arg5, Object arg6, InvocationService.InvocationListener arg7)
        throws InvocationException;
}
