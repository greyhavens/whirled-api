//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.whirled.ui.PlayerList;

import com.whirled.game.data.WhirledGameOccupantInfo;

import com.threerings.util.Comparable;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.threerings.util.Name;

import com.threerings.crowd.data.OccupantInfo;

/**
 * A record for tracking player data.
 */
public class GamePlayerRecord
    implements Comparable, Hashable
{
    /** The player's name. */
    public var name :Name;

    /** The player's oid, or 0 if the player is not present. */
    public var oid :int;

    /** The player's status, from PlayerList. */
    public var status :String;

    /** Is it an actual player in the game's players array? */
    public var isPlayer :Boolean;

    /** Optional score data to display. */
    public var scoreData :Object;

    /** Optional sort ordering for this record. */
    public var sortData :Object;

    /**
     * Called to configure this GamePlayerRecord.
     */
    public function setup (occInfo :OccupantInfo) :void
    {
        if (occInfo != null) {
            name = occInfo.username;
            oid = occInfo.bodyOid;
            var winfo :WhirledGameOccupantInfo = occInfo as WhirledGameOccupantInfo;
            if (winfo != null && !winfo.initialized) {
                status = PlayerList.STATUS_UNINITIALIZED;
            } else {
                status = (occInfo.status == OccupantInfo.IDLE)
                    ? PlayerList.STATUS_IDLE : PlayerList.STATUS_NORMAL;
            }

        } else {
            oid = 0;
            status = PlayerList.STATUS_GONE;
        }
    }

    /**
     * Set up an absent player.
     */
    public function setupAbsent (occName :Name) :void
    {
        name = occName;
        status = PlayerList.STATUS_GONE;
    }

    /**
     * Get any extra info about this player.
     * Used by subclasses.
     */
    public function getExtraInfo () :Object
    {
        return null;
    }

    // from Comparable
    public function compareTo (other :Object) :int
    {
        var that :GamePlayerRecord = other as GamePlayerRecord;

        // compare by sortData
        var cmp :int = compare(this.sortData, that.sortData);
        if (cmp == 0) {
            // if equal, compare by scoreData
            cmp = compare(this.scoreData, that.scoreData);
            if (cmp == 0) {
                // if equal, put actual players ahead of watchers
                cmp = compare(this.isPlayer, that.isPlayer);
                if (cmp == 0) {
                    // if equal, put people present ahead of those absent
                    var thisLeft :Boolean = (this.status == PlayerList.STATUS_GONE);
                    var thatLeft :Boolean = (that.status == PlayerList.STATUS_GONE);
                    cmp = compare(thatLeft, thisLeft);
                    if (cmp == 0) {
                        // if equal, compare by extraInfo (might need tweaking)
                        cmp = compare(this.getExtraInfo(), that.getExtraInfo());
                        if (cmp == 0) {
                            // if equal, compare by name (lowest first)
                            cmp = compare("" + that.name, "" + name);
                            if (cmp == 0) {
                                // if equal, compare by oid
                                cmp = compare(this.oid, that.oid);
                            }
                        }
                    }
                }
            }
        }
        return cmp;
    }

    // from Hashable
    public function hashCode () :int
    {
        if (name == null) {
            log.warning("Asked for hashCode when we have a null name!");
            return 0;
        }

        return name.hashCode();
    }

    // from Equalable via Hashable
    public function equals (other :Object) :Boolean
    {
        // object equality or deep, strict equals
        return other == this || (other is GamePlayerRecord && compareTo(other) == 0);
    }

    /**
     * Comparison utility method that sorts non-null over null, and otherwise
     * uses actionscript's greater than or less than operators to magically compare
     * most values.
     */
    protected static function compare (o1 :Object, o2 :Object) :int
    {
        if (o1 == o2) { // both null, or otherwise the same
            return 0;

        } else if (o1 == null || o2 == null) { // sort non-null above null
            return (o2 == null) ? -1 : 1; 

        } else { // use > operator to figure out the rest
            return (o1 > o2) ? -1 : 1;
        }
    }

    private static const log :Log = Log.getLog(GamePlayerRecord);
}
}
