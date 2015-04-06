//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;
import com.threerings.util.Integer;
import com.whirled.game.client.PrizeService;

/**
 * Provides the implementation of the <code>PrizeService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class PrizeMarshaller extends InvocationMarshaller
    implements PrizeService
{
    /** The method id used to dispatch <code>awardPrize</code> requests. */
    public static const AWARD_PRIZE :int = 1;

    // from interface PrizeService
    public function awardPrize (arg1 :String, arg2 :int, arg3 :InvocationService_InvocationListener) :void
    {
        var listener3 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(AWARD_PRIZE, [
            arg1, Integer.valueOf(arg2), listener3
        ]);
    }

    /** The method id used to dispatch <code>awardTrophy</code> requests. */
    public static const AWARD_TROPHY :int = 2;

    // from interface PrizeService
    public function awardTrophy (arg1 :String, arg2 :int, arg3 :InvocationService_InvocationListener) :void
    {
        var listener3 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(AWARD_TROPHY, [
            arg1, Integer.valueOf(arg2), listener3
        ]);
    }
}
}
