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
import com.whirled.game.data.PrizeMarshaller;

/**
 * Dispatches requests to the {@link PrizeProvider}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PrizeService.java.")
public class PrizeDispatcher extends InvocationDispatcher<PrizeMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public PrizeDispatcher (PrizeProvider provider)
    {
        this.provider = provider;
    }

    @Override
    public PrizeMarshaller createMarshaller ()
    {
        return new PrizeMarshaller();
    }

    @Override
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case PrizeMarshaller.AWARD_PRIZE:
            ((PrizeProvider)provider).awardPrize(
                source, (String)args[0], ((Integer)args[1]).intValue(), (InvocationService.InvocationListener)args[2]
            );
            return;

        case PrizeMarshaller.AWARD_TROPHY:
            ((PrizeProvider)provider).awardTrophy(
                source, (String)args[0], ((Integer)args[1]).intValue(), (InvocationService.InvocationListener)args[2]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
