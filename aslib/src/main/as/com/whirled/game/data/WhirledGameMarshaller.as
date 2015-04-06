//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.io.TypedArray;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ConfirmMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ResultMarshaller;
import com.threerings.util.Integer;
import com.threerings.util.langBoolean;
import com.whirled.game.client.WhirledGameService;
import flash.utils.ByteArray;

/**
 * Provides the implementation of the <code>WhirledGameService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class WhirledGameMarshaller extends InvocationMarshaller
    implements WhirledGameService
{
    /** The method id used to dispatch <code>addToCollection</code> requests. */
    public static const ADD_TO_COLLECTION :int = 1;

    // from interface WhirledGameService
    public function addToCollection (arg1 :String, arg2 :TypedArray /* of class [B */, arg3 :Boolean, arg4 :InvocationService_InvocationListener) :void
    {
        var listener4 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(ADD_TO_COLLECTION, [
            arg1, arg2, langBoolean.valueOf(arg3), listener4
        ]);
    }

    /** The method id used to dispatch <code>checkDictionaryWord</code> requests. */
    public static const CHECK_DICTIONARY_WORD :int = 2;

    // from interface WhirledGameService
    public function checkDictionaryWord (arg1 :String, arg2 :String, arg3 :String, arg4 :InvocationService_ResultListener) :void
    {
        var listener4 :InvocationMarshaller_ResultMarshaller = new InvocationMarshaller_ResultMarshaller();
        listener4.listener = arg4;
        sendRequest(CHECK_DICTIONARY_WORD, [
            arg1, arg2, arg3, listener4
        ]);
    }

    /** The method id used to dispatch <code>endGameWithScores</code> requests. */
    public static const END_GAME_WITH_SCORES :int = 3;

    // from interface WhirledGameService
    public function endGameWithScores (arg1 :TypedArray /* of int */, arg2 :TypedArray /* of int */, arg3 :int, arg4 :int, arg5 :InvocationService_InvocationListener) :void
    {
        var listener5 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener5.listener = arg5;
        sendRequest(END_GAME_WITH_SCORES, [
            arg1, arg2, Integer.valueOf(arg3), Integer.valueOf(arg4), listener5
        ]);
    }

    /** The method id used to dispatch <code>endGameWithWinners</code> requests. */
    public static const END_GAME_WITH_WINNERS :int = 4;

    // from interface WhirledGameService
    public function endGameWithWinners (arg1 :TypedArray /* of int */, arg2 :TypedArray /* of int */, arg3 :int, arg4 :InvocationService_InvocationListener) :void
    {
        var listener4 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener4.listener = arg4;
        sendRequest(END_GAME_WITH_WINNERS, [
            arg1, arg2, Integer.valueOf(arg3), listener4
        ]);
    }

    /** The method id used to dispatch <code>endRound</code> requests. */
    public static const END_ROUND :int = 5;

    // from interface WhirledGameService
    public function endRound (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(END_ROUND, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>endTurn</code> requests. */
    public static const END_TURN :int = 6;

    // from interface WhirledGameService
    public function endTurn (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(END_TURN, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>getCookie</code> requests. */
    public static const GET_COOKIE :int = 7;

    // from interface WhirledGameService
    public function getCookie (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(GET_COOKIE, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>getDictionaryLetterSet</code> requests. */
    public static const GET_DICTIONARY_LETTER_SET :int = 8;

    // from interface WhirledGameService
    public function getDictionaryLetterSet (arg1 :String, arg2 :String, arg3 :int, arg4 :InvocationService_ResultListener) :void
    {
        var listener4 :InvocationMarshaller_ResultMarshaller = new InvocationMarshaller_ResultMarshaller();
        listener4.listener = arg4;
        sendRequest(GET_DICTIONARY_LETTER_SET, [
            arg1, arg2, Integer.valueOf(arg3), listener4
        ]);
    }

    /** The method id used to dispatch <code>getDictionaryWords</code> requests. */
    public static const GET_DICTIONARY_WORDS :int = 9;

    // from interface WhirledGameService
    public function getDictionaryWords (arg1 :String, arg2 :String, arg3 :int, arg4 :InvocationService_ResultListener) :void
    {
        var listener4 :InvocationMarshaller_ResultMarshaller = new InvocationMarshaller_ResultMarshaller();
        listener4.listener = arg4;
        sendRequest(GET_DICTIONARY_WORDS, [
            arg1, arg2, Integer.valueOf(arg3), listener4
        ]);
    }

    /** The method id used to dispatch <code>getFromCollection</code> requests. */
    public static const GET_FROM_COLLECTION :int = 10;

    // from interface WhirledGameService
    public function getFromCollection (arg1 :String, arg2 :Boolean, arg3 :int, arg4 :String, arg5 :int, arg6 :InvocationService_ConfirmListener) :void
    {
        var listener6 :InvocationMarshaller_ConfirmMarshaller = new InvocationMarshaller_ConfirmMarshaller();
        listener6.listener = arg6;
        sendRequest(GET_FROM_COLLECTION, [
            arg1, langBoolean.valueOf(arg2), Integer.valueOf(arg3), arg4, Integer.valueOf(arg5), listener6
        ]);
    }

    /** The method id used to dispatch <code>makePlayerAI</code> requests. */
    public static const MAKE_PLAYER_AI :int = 11;

    // from interface WhirledGameService
    public function makePlayerAI (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(MAKE_PLAYER_AI, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>mergeCollection</code> requests. */
    public static const MERGE_COLLECTION :int = 12;

    // from interface WhirledGameService
    public function mergeCollection (arg1 :String, arg2 :String, arg3 :InvocationService_InvocationListener) :void
    {
        var listener3 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(MERGE_COLLECTION, [
            arg1, arg2, listener3
        ]);
    }

    /** The method id used to dispatch <code>restartGameIn</code> requests. */
    public static const RESTART_GAME_IN :int = 13;

    // from interface WhirledGameService
    public function restartGameIn (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(RESTART_GAME_IN, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>setCookie</code> requests. */
    public static const SET_COOKIE :int = 14;

    // from interface WhirledGameService
    public function setCookie (arg1 :ByteArray, arg2 :int, arg3 :InvocationService_InvocationListener) :void
    {
        var listener3 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(SET_COOKIE, [
            arg1, Integer.valueOf(arg2), listener3
        ]);
    }

    /** The method id used to dispatch <code>setTicker</code> requests. */
    public static const SET_TICKER :int = 15;

    // from interface WhirledGameService
    public function setTicker (arg1 :String, arg2 :int, arg3 :InvocationService_InvocationListener) :void
    {
        var listener3 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(SET_TICKER, [
            arg1, Integer.valueOf(arg2), listener3
        ]);
    }
}
}
