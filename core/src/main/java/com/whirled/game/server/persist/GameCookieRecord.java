//
// $Id$

package com.whirled.game.server.persist;

import com.samskivert.depot.Key;
import com.samskivert.depot.PersistentRecord;
import com.samskivert.depot.annotation.Column;
import com.samskivert.depot.annotation.Entity;
import com.samskivert.depot.annotation.Id;
import com.samskivert.depot.annotation.Index;
import com.samskivert.depot.expression.ColumnExp;

@Entity(name="GAME_COOKIES")
public class GameCookieRecord extends PersistentRecord
{
    // AUTO-GENERATED: FIELDS START
    public static final Class<GameCookieRecord> _R = GameCookieRecord.class;
    public static final ColumnExp<Integer> GAME_ID = colexp(_R, "gameId");
    public static final ColumnExp<Integer> USER_ID = colexp(_R, "userId");
    public static final ColumnExp<byte[]> COOKIE = colexp(_R, "cookie");
    // AUTO-GENERATED: FIELDS END

    public static final int SCHEMA_VERSION = 2;

    /** The id of the game for which this is a cookie. */
    @Id @Column(name="GAME_ID")
    public int gameId;

    /** The id of the user for which this is a cookie. */
    @Id @Index @Column(name="USER_ID")
    public int userId;

    /** The actual cookie, as a byte array. */
    @Column(name="COOKIE")
    public byte[] cookie;

    /** A no-argument constructor for deserialization. */
    public GameCookieRecord ()
    {
    }

    /** A constructor for configuring all the fields of this record. */
    public GameCookieRecord (int gameId, int userId, byte[] cookie)
    {
        super();
        this.gameId = gameId;
        this.userId = userId;
        this.cookie = cookie;
    }

    // AUTO-GENERATED: METHODS START
    /**
     * Create and return a primary {@link Key} to identify a {@link GameCookieRecord}
     * with the supplied key values.
     */
    public static Key<GameCookieRecord> getKey (int gameId, int userId)
    {
        return newKey(_R, gameId, userId);
    }

    /** Register the key fields in an order matching the getKey() factory. */
    static { registerKeyFields(GAME_ID, USER_ID); }
    // AUTO-GENERATED: METHODS END
}
