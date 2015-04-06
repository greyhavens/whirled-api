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
import com.whirled.game.data.ContentMarshaller;

/**
 * Dispatches requests to the {@link ContentProvider}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from ContentService.java.")
public class ContentDispatcher extends InvocationDispatcher<ContentMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public ContentDispatcher (ContentProvider provider)
    {
        this.provider = provider;
    }

    @Override
    public ContentMarshaller createMarshaller ()
    {
        return new ContentMarshaller();
    }

    @Override
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case ContentMarshaller.CONSUME_ITEM_PACK:
            ((ContentProvider)provider).consumeItemPack(
                source, ((Integer)args[0]).intValue(), (String)args[1], (InvocationService.InvocationListener)args[2]
            );
            return;

        case ContentMarshaller.PURCHASE_ITEM_PACK:
            ((ContentProvider)provider).purchaseItemPack(
                source, ((Integer)args[0]).intValue(), (String)args[1], (InvocationService.InvocationListener)args[2]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
