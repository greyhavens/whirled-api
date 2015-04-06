//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

import javax.annotation.Generated;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;
import com.whirled.game.client.PrizeService;

/**
 * Provides the implementation of the {@link PrizeService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PrizeService.java.")
public class PrizeMarshaller extends InvocationMarshaller
    implements PrizeService
{
    /** The method id used to dispatch {@link #awardPrize} requests. */
    public static final int AWARD_PRIZE = 1;

    // from interface PrizeService
    public void awardPrize (Client arg1, String arg2, int arg3, InvocationService.InvocationListener arg4)
    {
        ListenerMarshaller listener4 = new ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(arg1, AWARD_PRIZE, new Object[] {
            arg2, Integer.valueOf(arg3), listener4
        });
    }

    /** The method id used to dispatch {@link #awardTrophy} requests. */
    public static final int AWARD_TROPHY = 2;

    // from interface PrizeService
    public void awardTrophy (Client arg1, String arg2, int arg3, InvocationService.InvocationListener arg4)
    {
        ListenerMarshaller listener4 = new ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(arg1, AWARD_TROPHY, new Object[] {
            arg2, Integer.valueOf(arg3), listener4
        });
    }
}
