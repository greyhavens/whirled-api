//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game {

import flash.events.Event;

/**
 * Dispatched to let a game know when the player has been awarded coins.
 * This event is cancellable. If you would like to print your own coin award message and
 * suppress the default one, call preventDefault().
 */
public class CoinsAwardedEvent extends Event
{
    /**
     * An event type dispatched at the end of a game (before GAME_ENDED) to inform the game that
     * the player has earned coins.
     *
     * @eventType CoinsAwarded
     */
    public static const COINS_AWARDED :String = "CoinsAwarded";

    /**
     * Returns the amount of coins awarded to the player.
     */
    public function get amount () :int
    {
        return _amount;
    }

    /**
     * Returns the % of scores lower than the player's reported score, or -1 if no score was
     * reported.
     */
    public function get percentile () :int
    {
        return _percentile;
    }

    /**
     * Creates a new event.
     */
    public function CoinsAwardedEvent (amount :int, percentile :int)
    {
        super(COINS_AWARDED, false, true);
        _amount = amount;
        _percentile = percentile;
    }

    // from Event
    override public function clone () :Event
    {
        return new CoinsAwardedEvent(_amount, _percentile);
    }

    // from Event
    override public function toString () :String
    {
        return "CoinsAwardedEvent [type=" + type + ", amount=" + _amount +
            ", percentile=" + _percentile + "]";
    }

    /** The amount of coins awarded to the player. @private */
    protected var _amount :int;

    /** The % of scores lower than the player's reported score,
     * or -1 if no score was reported. @private */
    protected var _percentile :int;
}
}
