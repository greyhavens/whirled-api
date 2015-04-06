//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.util.Integer;

/**
 * An ActionScript version of the Java PropertySpaceService interface.
 */
public interface PropertySpaceService extends InvocationService
{
    // from Java interface PropertySpaceService
    function setProperty (arg1 :String, arg2 :Object, arg3 :Integer, arg4 :Boolean, arg5 :Boolean, arg6 :Object, arg7 :InvocationService_InvocationListener) :void;
}
}
