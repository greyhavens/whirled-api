//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

import com.threerings.io.SimpleStreamableObject;

/**
 * Contains metadata for a game add-on (level pack, item pack, trophy).
 */
public abstract class GameData extends SimpleStreamableObject
{
    public static final byte RESOLUTION_MARKER = 0;
    public static final byte LEVEL_DATA = 1;
    public static final byte ITEM_DATA = 2;
    public static final byte TROPHY_DATA = 3;
    public static final byte PRIZE_MARKER = 4;

    /** A unique identifier for this pack. */
    public String ident;

    /** A human readable name for this pack. */
    public String name;

    /** The URL from which this pack's media can be downloaded. */
    public String mediaURL;

    /**
     * Returns the type of this game data object.
     */
    public abstract byte getType ();
}
