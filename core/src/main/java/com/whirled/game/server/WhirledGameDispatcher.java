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
import com.whirled.game.data.WhirledGameMarshaller;

/**
 * Dispatches requests to the {@link WhirledGameProvider}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from WhirledGameService.java.")
public class WhirledGameDispatcher extends InvocationDispatcher<WhirledGameMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public WhirledGameDispatcher (WhirledGameProvider provider)
    {
        this.provider = provider;
    }

    @Override
    public WhirledGameMarshaller createMarshaller ()
    {
        return new WhirledGameMarshaller();
    }

    @Override
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case WhirledGameMarshaller.ADD_TO_COLLECTION:
            ((WhirledGameProvider)provider).addToCollection(
                source, (String)args[0], (byte[][])args[1], ((Boolean)args[2]).booleanValue(), (InvocationService.InvocationListener)args[3]
            );
            return;

        case WhirledGameMarshaller.CHECK_DICTIONARY_WORD:
            ((WhirledGameProvider)provider).checkDictionaryWord(
                source, (String)args[0], (String)args[1], (String)args[2], (InvocationService.ResultListener)args[3]
            );
            return;

        case WhirledGameMarshaller.END_GAME_WITH_SCORES:
            ((WhirledGameProvider)provider).endGameWithScores(
                source, (int[])args[0], (int[])args[1], ((Integer)args[2]).intValue(), ((Integer)args[3]).intValue(), (InvocationService.InvocationListener)args[4]
            );
            return;

        case WhirledGameMarshaller.END_GAME_WITH_WINNERS:
            ((WhirledGameProvider)provider).endGameWithWinners(
                source, (int[])args[0], (int[])args[1], ((Integer)args[2]).intValue(), (InvocationService.InvocationListener)args[3]
            );
            return;

        case WhirledGameMarshaller.END_ROUND:
            ((WhirledGameProvider)provider).endRound(
                source, ((Integer)args[0]).intValue(), (InvocationService.InvocationListener)args[1]
            );
            return;

        case WhirledGameMarshaller.END_TURN:
            ((WhirledGameProvider)provider).endTurn(
                source, ((Integer)args[0]).intValue(), (InvocationService.InvocationListener)args[1]
            );
            return;

        case WhirledGameMarshaller.GET_COOKIE:
            ((WhirledGameProvider)provider).getCookie(
                source, ((Integer)args[0]).intValue(), (InvocationService.InvocationListener)args[1]
            );
            return;

        case WhirledGameMarshaller.GET_DICTIONARY_LETTER_SET:
            ((WhirledGameProvider)provider).getDictionaryLetterSet(
                source, (String)args[0], (String)args[1], ((Integer)args[2]).intValue(), (InvocationService.ResultListener)args[3]
            );
            return;

        case WhirledGameMarshaller.GET_DICTIONARY_WORDS:
            ((WhirledGameProvider)provider).getDictionaryWords(
                source, (String)args[0], (String)args[1], ((Integer)args[2]).intValue(), (InvocationService.ResultListener)args[3]
            );
            return;

        case WhirledGameMarshaller.GET_FROM_COLLECTION:
            ((WhirledGameProvider)provider).getFromCollection(
                source, (String)args[0], ((Boolean)args[1]).booleanValue(), ((Integer)args[2]).intValue(), (String)args[3], ((Integer)args[4]).intValue(), (InvocationService.ConfirmListener)args[5]
            );
            return;

        case WhirledGameMarshaller.MAKE_PLAYER_AI:
            ((WhirledGameProvider)provider).makePlayerAI(
                source, ((Integer)args[0]).intValue(), (InvocationService.InvocationListener)args[1]
            );
            return;

        case WhirledGameMarshaller.MERGE_COLLECTION:
            ((WhirledGameProvider)provider).mergeCollection(
                source, (String)args[0], (String)args[1], (InvocationService.InvocationListener)args[2]
            );
            return;

        case WhirledGameMarshaller.RESTART_GAME_IN:
            ((WhirledGameProvider)provider).restartGameIn(
                source, ((Integer)args[0]).intValue(), (InvocationService.InvocationListener)args[1]
            );
            return;

        case WhirledGameMarshaller.SET_COOKIE:
            ((WhirledGameProvider)provider).setCookie(
                source, (byte[])args[0], ((Integer)args[1]).intValue(), (InvocationService.InvocationListener)args[2]
            );
            return;

        case WhirledGameMarshaller.SET_TICKER:
            ((WhirledGameProvider)provider).setTicker(
                source, (String)args[0], ((Integer)args[1]).intValue(), (InvocationService.InvocationListener)args[2]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
