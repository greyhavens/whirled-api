//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java ContentService interface.
 */
public interface ContentService extends InvocationService
{
    // from Java interface ContentService
    function consumeItemPack (arg1 :int, arg2 :String, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface ContentService
    function purchaseItemPack (arg1 :int, arg2 :String, arg3 :InvocationService_InvocationListener) :void;
}
}
