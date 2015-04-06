//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.server;

import java.util.prefs.Preferences;

import com.google.inject.Singleton;

import com.samskivert.util.ResultListener;

/**
 * A manager that stores cookies in Java preferences on the local machine.  This should only be
 * used for developer testing.
 */
@Singleton
public class PrefsCookieManager
    implements GameCookieManager
{
    public PrefsCookieManager ()
    {
        _prefs = Preferences.userRoot().node("gameCookieManager/" + System.getProperty("gameName"));
    }

    // from interface GameCookieManager
    public void getCookie (int gameId, int userId, ResultListener<byte[]> rl)
    {
        if (userId == 0) {
            rl.requestCompleted(null);
            return;
        }
        rl.requestCompleted(_prefs.getByteArray(gameId + ":" + userId, (byte[])null));
    }

    // from interface GameCookieManager
    public void setCookie (int gameId, int userId, byte[] cookie)
    {
        if (userId == 0) {
            return; // fail to save, silently
        }
        _prefs.putByteArray(gameId + ":" + userId, cookie);
    }

    /** Our local store, which is used when testing. */
    protected Preferences _prefs;
}
