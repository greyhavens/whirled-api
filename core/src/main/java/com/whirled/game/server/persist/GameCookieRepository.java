//
// $Id$

package com.whirled.game.server.persist;

import java.util.Collection;
import java.util.Set;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.samskivert.depot.DepotRepository;
import com.samskivert.depot.PersistenceContext;
import com.samskivert.depot.PersistentRecord;
import com.samskivert.depot.clause.Where;

/**
 * Provides storage services for user cookies used in games.
 */
@Singleton
public class GameCookieRepository extends DepotRepository
{
    @Inject public GameCookieRepository (PersistenceContext ctx)
    {
        super(ctx);
    }

    /**
     * Get the specified game cookie, or null if none.
     */
    public byte[] getCookie (int gameId, int playerId)
    {
        GameCookieRecord record = load(GameCookieRecord.getKey(gameId, playerId));
        return record != null ? record.cookie : null;
    }

    /**
     * Set the specified user's game cookie.
     */
    public void setCookie (int gameId, int playerId, byte[] cookie)
    {
        if (cookie != null) {
            store(new GameCookieRecord(gameId, playerId, cookie));
        } else {
            delete(GameCookieRecord.getKey(gameId, playerId));
        }
    }

    /**
     * Purges all data associated with the supplied players.
     */
    public void purgePlayers (Collection<Integer> playerIds)
    {
        deleteAll(GameCookieRecord.class, new Where(GameCookieRecord.USER_ID.in(playerIds)));
    }

    @Override // from DepotRepository
    protected void getManagedRecords (Set<Class<? extends PersistentRecord>> classes)
    {
        classes.add(GameCookieRecord.class);
    }
}
