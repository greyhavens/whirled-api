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
import com.whirled.game.client.WhirledGameService;

/**
 * Defines the server-side of the {@link WhirledGameService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from WhirledGameService.java.")
public interface WhirledGameProvider extends InvocationProvider
{
    /**
     * Handles a {@link WhirledGameService#addToCollection} request.
     */
    void addToCollection (ClientObject caller, String arg1, byte[][] arg2, boolean arg3, InvocationService.InvocationListener arg4)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#checkDictionaryWord} request.
     */
    void checkDictionaryWord (ClientObject caller, String arg1, String arg2, String arg3, InvocationService.ResultListener arg4)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#endGameWithScores} request.
     */
    void endGameWithScores (ClientObject caller, int[] arg1, int[] arg2, int arg3, int arg4, InvocationService.InvocationListener arg5)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#endGameWithWinners} request.
     */
    void endGameWithWinners (ClientObject caller, int[] arg1, int[] arg2, int arg3, InvocationService.InvocationListener arg4)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#endRound} request.
     */
    void endRound (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#endTurn} request.
     */
    void endTurn (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#getCookie} request.
     */
    void getCookie (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#getDictionaryLetterSet} request.
     */
    void getDictionaryLetterSet (ClientObject caller, String arg1, String arg2, int arg3, InvocationService.ResultListener arg4)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#getDictionaryWords} request.
     */
    void getDictionaryWords (ClientObject caller, String arg1, String arg2, int arg3, InvocationService.ResultListener arg4)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#getFromCollection} request.
     */
    void getFromCollection (ClientObject caller, String arg1, boolean arg2, int arg3, String arg4, int arg5, InvocationService.ConfirmListener arg6)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#makePlayerAI} request.
     */
    void makePlayerAI (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#mergeCollection} request.
     */
    void mergeCollection (ClientObject caller, String arg1, String arg2, InvocationService.InvocationListener arg3)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#restartGameIn} request.
     */
    void restartGameIn (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#setCookie} request.
     */
    void setCookie (ClientObject caller, byte[] arg1, int arg2, InvocationService.InvocationListener arg3)
        throws InvocationException;

    /**
     * Handles a {@link WhirledGameService#setTicker} request.
     */
    void setTicker (ClientObject caller, String arg1, int arg2, InvocationService.InvocationListener arg3)
        throws InvocationException;
}
