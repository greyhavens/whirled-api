//
// $Id$

package com.whirled.game.data;

import com.threerings.presents.dobj.DSet;

/**
 * Represents a user's game-specific cookie data.
 */
public class UserCookie
    implements DSet.Entry
{
    /** The id of the player that has this cookie. */
    public int playerId;

    /** The cookie value. */
    public byte[] cookie;

    /**
     */
    public UserCookie (int playerId, byte[] cookie)
    {
        this.playerId = playerId;
        this.cookie = cookie;
    }

    // from DSet.Entry
    public Comparable<?> getKey ()
    {
        return playerId;
    }
}
