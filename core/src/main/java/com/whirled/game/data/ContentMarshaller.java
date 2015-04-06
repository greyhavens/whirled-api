//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

import javax.annotation.Generated;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;
import com.whirled.game.client.ContentService;

/**
 * Provides the implementation of the {@link ContentService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from ContentService.java.")
public class ContentMarshaller extends InvocationMarshaller
    implements ContentService
{
    /** The method id used to dispatch {@link #consumeItemPack} requests. */
    public static final int CONSUME_ITEM_PACK = 1;

    // from interface ContentService
    public void consumeItemPack (Client arg1, int arg2, String arg3, InvocationService.InvocationListener arg4)
    {
        ListenerMarshaller listener4 = new ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(arg1, CONSUME_ITEM_PACK, new Object[] {
            Integer.valueOf(arg2), arg3, listener4
        });
    }

    /** The method id used to dispatch {@link #purchaseItemPack} requests. */
    public static final int PURCHASE_ITEM_PACK = 2;

    // from interface ContentService
    public void purchaseItemPack (Client arg1, int arg2, String arg3, InvocationService.InvocationListener arg4)
    {
        ListenerMarshaller listener4 = new ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(arg1, PURCHASE_ITEM_PACK, new Object[] {
            Integer.valueOf(arg2), arg3, listener4
        });
    }
}
