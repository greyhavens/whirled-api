//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

import com.google.common.base.Objects;

import com.threerings.presents.dobj.DSet.Entry;
import com.threerings.io.SimpleStreamableObject;

/**
 * Contains information on content owned by a player for a game.
 */
public class GameContentOwnership extends SimpleStreamableObject
    implements Entry, Comparable<GameContentOwnership>
{
    /** The game to which this content pertains. */
    public int gameId;

    /** The type of this content; see {@link GameData}. */
    public byte type;

    /** The identifier for this content. */
    public String ident;

    /** The number of copies of this content owned by the player. */
    public int count;

    /** Used when unserializing. */
    public GameContentOwnership ()
    {
    }

    /**
     * Creates an ownership record for the specified game, type and ident with an ownership count
     * of 1 (used for content for which multiple copies cannot be owned).
     */
    public GameContentOwnership (int gameId, byte type, String ident)
    {
        this(gameId, type, ident, 1);
    }

    /**
     * Creates an ownership record for the specified game, type, ident and ownership count.
     */
    public GameContentOwnership (int gameId, byte type, String ident, int count)
    {
        this.gameId = gameId;
        this.type = type;
        this.ident = ident;
        this.count = count;
    }

    // from DSet.Entry
    public Comparable<?> getKey ()
    {
        return this;
    }

    // from Comparable
    public int compareTo (GameContentOwnership oo)
    {
        int rv = (oo.gameId - gameId);
        if (rv != 0) {
            return rv;
        }
        rv = (oo.type - type);
        if (rv != 0) {
            return rv;
        }
        return oo.ident.compareTo(ident);
    }

    @Override // from Object
    public boolean equals (Object other)
    {
        return (compareTo((GameContentOwnership)other) == 0);
    }
    
    @Override // from Object
    public int hashCode ()
    {
    	return Objects.hashCode(gameId, type, ident, count);
    }
}
