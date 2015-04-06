//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

/**
 * Contains 'bags' game services. Do not instantiate this class yourself, access it via
 * GameControl.services.bags.
 *
 * Bags are secret collections containing non-unique elements that are stored on the server. They
 * can be used to implement game features where clients can't be trusted to not sniff their network.
 * 
 * For example you could create a bag called "dice" and fill it with [ 1, 2, 3, 4, 5, 6 ]. Now you
 * can roll the die with _ctrl.services.bags.pick("dice", 1, "diceProperty");
 */
public class BagsSubControl extends AbstractSubControl
{
    /** 
     * Player id constant used by <code>pick</code> and <code>deal</code> indicating that elements 
     * should be picked or dealt publicly to all players.
     * @see #pick()
     * @see #deal()
     */
    public static const SHOW_TO_ALL :int = 0;

    /**
     * @private Constructed via GameControl.
     */
    public function BagsSubControl (parent :AbstractControl)
    {
        super(parent);
    }

    /**
     * Create a bag containing the specified values, clearing any previous bag with the same name.
     */
    public function create (bagName :String, values :Array) :void
    {
        populate(bagName, values, true);
    }

    /**
     * Add values to an existing bag. If it doesn't exist, it will be created.
     */
    public function addTo (bagName :String, values :Array) :void
    {
        populate(bagName, values, false);
    }

    /**
     * Merge all values from the specified bag into the other bag. The source bag will be destroyed.
     * The elements from the source bag will be shuffled and appended to the end of the destination
     * bag.
     */
    public function merge (srcBag :String, intoBag :String) :void
    {
        callHostCode("mergeCollection_v1", srcBag, intoBag);
    }

    /**
     * Pick (do not remove) the specified number of elements from a bag, and distribute them to a
     * specific player or set them as a property in the game data.
     *
     * @param bagName the collection name.
     * @param count the number of elements to pick
     * @param msgOrPropName the name of the message or property that will contain the picked
     * elements.
     * @param playerId if <code>SHOW_TO_ALL</code> (or unset), the picked elements should be set on
     * the gameObject as a property for all to see. If a playerId is specified, only that player
     * will receive the elements as a message.
     * @see #SHOW_TO_ALL
     */
    // TODO: a way to specify exclusive picks vs. duplicate-OK picks?
    public function pick (
        bagName :String, count :int, msgOrPropName :String,
        playerId :int = SHOW_TO_ALL) :void
    {
        getFrom(bagName, count, msgOrPropName, playerId, false, null);
    }

    /**
     * Deal (remove) the specified number of elements from a bag, and distribute them to a 
     * specific player or set them as a property in the game data. Fails if the named collection 
     * could not be found or does not contain enough elements to complete the deal.
     *
     * @param bagName the collection name.
     * @param count the number of elements to pick
     * @param msgOrPropName the name of the message or property that will contain the picked 
     * elements.
     * @param callback optional function to call after the deal has completed. If provided, the 
     * signature of the function must be compatible with the following:
     *     <listing version="3.0">
     *         function onDealt (count :int) :void {}
     *     </listing>
     * If the deal fails for any reason, the count will be 0, otherwise it will be the number of 
     * elements dealt.
     * @param playerId if <code>SHOW_TO_ALL</code> (or unset), the picked elements should be set on 
     * the gameObject as a property for all to see. If a playerId is specified, only that player 
     * will receive the elements as a message.
     * @see #SHOW_TO_ALL
     */
    public function deal (
        bagName :String, count :int, msgOrPropName :String,
        callback :Function = null, playerId :int = SHOW_TO_ALL) :void
    {
        getFrom(bagName, count, msgOrPropName, playerId, true, callback);
    }

    /**
     * Helper method for create and addTo.
     * @private
     */
    protected function populate (
        bagName :String, values :Array, clearExisting :Boolean) :void
    {
        callHostCode("populateCollection_v1", bagName, values, clearExisting);
    }

    /**
     * Helper method for pick and deal.
     * @private
     */
    protected function getFrom (
        bagName :String, count :int, msgOrPropName :String, playerId :int,
        consume :Boolean, callback :Function) :void
    {
        callHostCode("getFromCollection_v2", bagName, count, msgOrPropName,
            playerId, consume, callback);
    }
}
}
