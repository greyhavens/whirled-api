//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.io.TypedArray;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import flash.utils.ByteArray;

/**
 * An ActionScript version of the Java WhirledGameService interface.
 */
public interface WhirledGameService extends InvocationService
{
    // from Java interface WhirledGameService
    function addToCollection (arg1 :String, arg2 :TypedArray /* of class [B */, arg3 :Boolean, arg4 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function checkDictionaryWord (arg1 :String, arg2 :String, arg3 :String, arg4 :InvocationService_ResultListener) :void;

    // from Java interface WhirledGameService
    function endGameWithScores (arg1 :TypedArray /* of int */, arg2 :TypedArray /* of int */, arg3 :int, arg4 :int, arg5 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function endGameWithWinners (arg1 :TypedArray /* of int */, arg2 :TypedArray /* of int */, arg3 :int, arg4 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function endRound (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function endTurn (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function getCookie (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function getDictionaryLetterSet (arg1 :String, arg2 :String, arg3 :int, arg4 :InvocationService_ResultListener) :void;

    // from Java interface WhirledGameService
    function getDictionaryWords (arg1 :String, arg2 :String, arg3 :int, arg4 :InvocationService_ResultListener) :void;

    // from Java interface WhirledGameService
    function getFromCollection (arg1 :String, arg2 :Boolean, arg3 :int, arg4 :String, arg5 :int, arg6 :InvocationService_ConfirmListener) :void;

    // from Java interface WhirledGameService
    function makePlayerAI (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function mergeCollection (arg1 :String, arg2 :String, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function restartGameIn (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function setCookie (arg1 :ByteArray, arg2 :int, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface WhirledGameService
    function setTicker (arg1 :String, arg2 :int, arg3 :InvocationService_InvocationListener) :void;
}
}
