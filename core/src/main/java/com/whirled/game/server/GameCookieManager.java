//
// $Id$

package com.whirled.game.server;

import com.samskivert.util.ResultListener;

/**
 * Manages access to game cookies.
 */
public interface GameCookieManager
{
    /**
     * Gets the specified user's cookie.
     */
    public void getCookie (int gameId, int userId, ResultListener<byte[]> rl);

    /**
     * Sets the specified user's cookie.
     */
    public void setCookie (int gameId, int userId, byte[] cookie);
}
