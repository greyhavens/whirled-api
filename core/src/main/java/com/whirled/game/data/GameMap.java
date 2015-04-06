//
// $Id$

package com.whirled.game.data;

import java.util.Arrays;

import com.samskivert.util.IntMap;

import com.threerings.util.StreamableHashIntMap;

public class GameMap extends StreamableHashIntMap<byte[]>
{
    /** Suitable for unserialization. */
    public GameMap ()
    {
    }

    @Override
    public boolean equals (Object other)
    {
        if (other instanceof GameMap) {
            GameMap that = (GameMap) other;
            if (that.size() == this.size()) {
                for (IntMap.IntEntry<byte[]> entry : this.intEntrySet()) {
                    if (!Arrays.equals(entry.getValue(), that.get(entry.getIntKey()))) {
                        return false;
                    }
                }
                return true;
            }
        }
        return false;
    }

    // the default hashCode implementation should work with this
}
