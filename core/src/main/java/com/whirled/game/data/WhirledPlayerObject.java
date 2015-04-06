//
// $Id$

package com.whirled.game.data;

import javax.annotation.Generated;
import com.threerings.presents.dobj.DSet;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

/**
 * Body for playing whirled games.
 */
public class WhirledPlayerObject extends BodyObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>gameContent</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String GAME_CONTENT = "gameContent";
    // AUTO-GENERATED: FIELDS END

    /** Messages containing private inter-player messages begin with this. */
    public static final String PRIVATE_USER_MESSAGE_PREFIX = "Umsg:";

    /** Ident for {@link GameData#RESOLUTION_MARKER} content during resolution. */
    public static final String RESOLVING = "resolving";

    /** Ident for {@link GameData#RESOLUTION_MARKER} content after resolution. */
    public static final String RESOLVED = "resolved";

    /** Contains information on player's ownership of game content (populated lazily). */
    public DSet<GameContentOwnership> gameContent = new DSet<GameContentOwnership>();

    /**
     * Computes the name for private user messages for a given game id.
     */
    public static String getMessageName (int gameId)
    {
        return PRIVATE_USER_MESSAGE_PREFIX + gameId;
    }

    /**
     * Checks if a the name of a private user message is from the given game id.
     */
    public static boolean isFromGame (String eventName, int gameId)
    {
        return eventName.equals(getMessageName(gameId));
    }

    /**
     * Returns true if content is resolved for the specified game, false if it is not yet ready.
     */
    public boolean isContentResolved (int gameId)
    {
        return ownsGameContent(gameId, GameData.RESOLUTION_MARKER, RESOLVED);
    }

    /**
     * Returns true if content is being resolved for the specified game, false if it is ready or
     * resolution is not yet initiated.
     */
    public boolean isContentResolving (int gameId)
    {
        return ownsGameContent(gameId, GameData.RESOLUTION_MARKER, RESOLVING);
    }

    /**
     * Returns true if this player owns the specified piece of game content. <em>Note:</em> the
     * content must have previously been resolved, which happens when the player enters the game in
     * question.
     */
    public boolean ownsGameContent (int gameId, byte type, String ident)
    {
        return countGameContent(gameId, type, ident) > 0;
    }

    /**
     * Returns the number of copies of the specified game content owned by this player.
     * <em>Note:</em> the content must have previously been resolved, which happens when the player
     * enters the game in question.
     */
    public int countGameContent (int gameId, byte type, String ident)
    {
        GameContentOwnership gco = gameContent.get(new GameContentOwnership(gameId, type, ident));
        return (gco == null) ? 0 : gco.count;
    }

    // from BodyObject
    @Override public OccupantInfo createOccupantInfo (PlaceObject plObj)
    {
        if (plObj instanceof WhirledGameObject) {
            return new WhirledGameOccupantInfo(this);

        } else {
            return super.createOccupantInfo(plObj);
        }
    }

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the specified entry be added to the
     * <code>gameContent</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToGameContent (GameContentOwnership elem)
    {
        requestEntryAdd(GAME_CONTENT, gameContent, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>gameContent</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromGameContent (Comparable<?> key)
    {
        requestEntryRemove(GAME_CONTENT, gameContent, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>gameContent</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateGameContent (GameContentOwnership elem)
    {
        requestEntryUpdate(GAME_CONTENT, gameContent, elem);
    }

    /**
     * Requests that the <code>gameContent</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setGameContent (DSet<GameContentOwnership> value)
    {
        requestAttributeChange(GAME_CONTENT, value, this.gameContent);
        DSet<GameContentOwnership> clone = (value == null) ? null : value.clone();
        this.gameContent = clone;
    }
    // AUTO-GENERATED: METHODS END
}
