//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.TargetedSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.PropertySubControlImpl;

/**
 * Dispatched when this player has just entered a room (or was already in the room and just started
 * playing the game).
 *
 * @eventType com.whirled.avrg.AVRGamePlayerEvent.ENTERED_ROOM
 * @see com.whirled.avrg.GameSubControlServer#event:playerJoinedGame
 */
[Event(name="enteredRoom", type="com.whirled.avrg.AVRGamePlayerEvent")]

/**
 * Dispatched when this player has left a room (or has chosen to leave the game).
 *
 * @eventType com.whirled.avrg.AVRGamePlayerEvent.LEFT_ROOM
 * @see com.whirled.avrg.GameSubControlServer#event:playerQuitGame
 */
[Event(name="leftRoom", type="com.whirled.avrg.AVRGamePlayerEvent")]


/**
 * Dispatched when this player completes a task and receives a coin payout.
 *
 * @eventType com.whirled.avrg.AVRGamePlayerEvent.TASK_COMPLETED
 * @see #completeTask()
 */
[Event(name="taskCompleted", type="com.whirled.avrg.AVRGamePlayerEvent")]

/**
 * Provides services for a single player of an AVRG to the server agent and client.
 */
public class PlayerSubControlBase extends TargetedSubControl
{
    /** @private */
    public function PlayerSubControlBase (ctrl :AbstractControl, targetId :int = 0)
    {
        super(ctrl, targetId);
    }

    /**
     * Accesses the read-write properties of this player. Properties marked as such will be
     * persisted and restored whenever the player joins the game. Persistent properties should
     * only be used when genuinely necessary. Persisting properties on a guest player will have
     * no effect.
     *
     * @see com.whirled.net.NetConstants#makePersistent()
     */
    public function get props () :PropertySubControl
    {
        return _props;
    }

    /**
     * Gets the id of this player. For joined members, this id is the member id and can be used to
     * view the member's profile (www.whirled.com/#people-{id}).
     */
    public function getPlayerId () :int
    {
        // subclasses take care of this
        return 0;
    }

    /**
     * Get the party id of this player.
     */
    public function getPartyId () :int
    {
        return callHostCode("player_getPartyId_v1") as int;
    }

    /**
     * Accesses the id of the room that this player is in. Returns 0 if the player is not in
     * any room. This may happen immediately after the player joins the game or just after
     * the player leaves another room.
     */
    public function getRoomId () :int
    {
        return callHostCode("player_getRoomId_v1") as int;
    }

    /**
     * Quits the game for this player. This method should be called for example when the user
     * closes the HUD of a game.
     */
    public function deactivateGame () :void
    {
        callHostCode("deactivateGame_v1");
    }

    /**
     * Returns all item packs owned by this client's player (the default) or a specified player.
     * The packs are returned as an array of objects with the following properties:
     *
     * <pre>
     * ident - string identifier of item pack
     * name - human readable name of item pack
     * mediaURL - URL for item pack content
     * </pre>
     */
    public function getPlayerItemPacks () :Array
    {
        return (callHostCode("getPlayerItemPacks_v1") as Array);
    }

    /**
     * Returns all level packs owned by this client's player (the default) or a specified player.
     * The packs are returned as an array of objects with the following properties:
     *
     * <pre>
     * ident - string identifier of item pack
     * name - human readable name of item pack
     * mediaURL - URL for item pack content
     * premium - boolean indicating that content is premium or not
     * </pre>
     */
    public function getPlayerLevelPacks () :Array
    {
        return (callHostCode("getPlayerLevelPacks_v1") as Array);
    }

    /**
     * Returns true if this client's player (the default) or a specified player has the trophy
     * with the specified identifier.
     */
    public function holdsTrophy (ident :String) :Boolean
    {
        return (callHostCode("holdsTrophy_v1", ident) as Boolean);
    }

    /**
     * This method calculates and awards a coin payout for the player. The actual amount is not
     * under the direct control of the developer, but is calculated by Whirled from factors such
     * as the number of people playing the game and the frequency and size of payouts the game
     * makes.
     *
     * The payout factor is a number that should lie between 0 and 1, and the coin payout is a
     * multiple of this amount. This means if the game calls this method with a factor of 0.3 for
     * one player and 0.6 for another, the second player is guaranteed to get twice as many coins
     * as the first. Use this guarantee to develop a fair payout structure for your game.
     *
     * The taskId is not used by the server at all. Its only purpose is to be echoed back in the
     * AVRGamePlayerEvent.TASK_COMPLETED event that is dispatched as a result of this call. This
     * event contains the taskId that was sent in along with the precise number of coins that were
     * actually awarded to the player. The typical use of this event would be to display a nice
     * popup window or graphical effect to salute the player's achivement, optionally including
     * the coin amount.
     */
    public function completeTask (taskId :String, payout :Number) :void
    {
        callHostCode("completeTask_v1", taskId, payout);
    }

    /**
     * Plays an action on this players avatar.
     * @see com.whirled.AvatarControl#event:actionTriggered
     */
    public function playAvatarAction (action :String) :void
    {
        callHostCode("playAvatarAction_v1", action);
    }

    /**
     * Sets the stats of this player's avatar.
     * @see com.whirled.ActorControl#event:stateChanged
     */
    public function setAvatarState (state :String) :void
    {
        callHostCode("setAvatarState_v1", state);
    }

    /**
     * Sets the move speed of this player's avatar. TODO: implement and unmark private
     * @private
     */
    public function setAvatarMoveSpeed (pixelsPerSecond :Number) :void
    {
        callHostCode("setAvatarMoveSpeed_v1", pixelsPerSecond);
    }

    /**
     * Sets the location and orientation of this player's avatar in room coordinates.
     * @see http://wiki.whirled.com/Coordinate_systems
     */
    public function setAvatarLocation (x :Number, y :Number, z: Number, orient :Number) :void
    {
        callHostCode("setAvatarLocation_v1", x, y, z, orient);
    }

    /**
     * Sets the orientation of this player's avatar. TODO: implement and unmark private
     * @private
     */
    public function setAvatarOrientation (orient :Number) :void
    {
        callHostCode("setAvatarOrientation_v1", orient);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertySubControlImpl(
            _parent, _targetId, "player_getGameData_v1", "player_setProperty_v1");
        return [ _props ];
    }

    /** @private */
    internal function taskCompleted_v1 (task :String, amount :int) :Boolean
    {
        var evt :AVRGamePlayerEvent = new AVRGamePlayerEvent(
            AVRGamePlayerEvent.TASK_COMPLETED, _targetId, task, amount, true);
        dispatch(evt);
        return evt.isDefaultPrevented();
    }

    /** @private */
    internal function leftRoom_v1 (scene :int) :void
    {
        dispatch(new AVRGamePlayerEvent(AVRGamePlayerEvent.LEFT_ROOM, _targetId, null, scene));
    }

    /** @private */
    internal function enteredRoom_v1 (newScene :int) :void
    {
        dispatch(new AVRGamePlayerEvent(
            AVRGamePlayerEvent.ENTERED_ROOM, _targetId, null, newScene));
    }

    /** @private */
    protected var _props :PropertySubControlImpl;
}
}
