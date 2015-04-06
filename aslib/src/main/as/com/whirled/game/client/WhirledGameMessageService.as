//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.io.TypedArray;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java WhirledGameMessageService interface.
 */
public interface WhirledGameMessageService extends InvocationService
{
    // from Java interface WhirledGameMessageService
    function sendMessage (arg1 :String, arg2 :Object, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameMessageService
    function sendPrivateMessage (arg1 :String, arg2 :Object, arg3 :TypedArray /* of int */, arg4 :InvocationService_InvocationListener) :void;
}
}
