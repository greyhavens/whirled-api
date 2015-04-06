//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.TargetedSubControl;
import com.whirled.game.GameContentEvent;
import com.whirled.net.MessageReceivedEvent;

/**
 * Dispatched when a message arrives with information that is not part of the shared game state.
 *
 * @eventType com.whirled.net.MessageReceivedEvent.MESSAGE_RECEIVED
 * @see PlayerSubControlServer#sendMessage()
 */
[Event(name="MsgReceived", type="com.whirled.net.MessageReceivedEvent")]

/**
 * Provides services for the client's player of an AVRG.
 * @see AVRGameControl#player
 */
public class PlayerSubControlClient extends PlayerSubControlBase
{
    /** @private */
    public function PlayerSubControlClient (ctrl :AbstractControl)
    {
        super(ctrl, 0);
    }

    /** @inheritDoc */
    // from PlayerSubControlBase
    override public function getPlayerId () :int
    {
        return callHostCode("getPlayerId_v1");
    }

    /** @inheritDoc */
    // from PlayerSubControlBase
    override public function getPlayerName () :String
    {
        return callHostCode("getPlayerName_v1");
    }

    /**
     * Returns the player's Facebook info in a two element array. The first element is the player's
     * Facebook id the second is their current Facebook session token (or the empty string if we
     * have no session token information for the player). The return value will be null if the
     * player is not currently playing the game through the game's Facebook app.
     *
     * <p> The Facebook id is only available to games that have specified a Facebook app
     * configuration for their game and only when the player is playing the game through the
     * Facebook app. </p>
     */
    public function getFacebookInfo () :Array
    {
        return callHostCode("getFacebookInfo_v1");
    }

    /**
     * Returns the master item id of the avatar being worn by the player, or zero for
     * guests (ghosts) or people wearing the default tofu. The master id will be the
     * same for all purchased copies of a particular catalog avatar and will be a
     * unique value for every original (non-catalog purchased) avatar item.
     */
    public function getAvatarMasterItemId () :int
    {
        return callHostCode("getAvatarMasterItemId_v1");
    }

    /**
     * Requests to consume the specified item pack. The player must currently own at least one copy
     * of the item pack. This will display a standard dialog asking the player if they wish to
     * consume the pack.
     *
     * <p> If the player accepts the request to consume the item pack, a
     * GameContentEvent.PLAYER_CONTENT_CONSUMED event will be dispatched on this control (on both
     * the client and server). </p>
     *
     * @param ident the identifier of the item pack to be consumed.
     * @param msg a message to display in the dialog to help the player understand what's going on.
     *
     * @return true if the dialog was shown, false if the dialog was not shown because the player
     * is known not to own at least one copy of the item pack.
     */
    public function requestConsumeItemPack (ident :String, msg :String) :Boolean
    {
        return (callHostCode("requestConsumeItemPack_v1", ident, msg) as Boolean);
    }

    /** @private */
    override public function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["taskCompleted_v1"] = taskCompleted_v1;
        o["notifyGameContentAdded_v1"] = notifyGameContentAdded_v1;
        o["notifyGameContentConsumed_v1"] = notifyGameContentConsumed_v1;

        // the client backend does not send in targetId
        o["player_propertyWasSet_v1"] = _props.propertyWasSet_v1;

        o["player_messageReceived_v1"] = player_messageReceived_v1;
    }

    private function player_messageReceived_v1 (name :String, value :Object, sender :int) :void
    {
        dispatchEvent(new MessageReceivedEvent(name, value, sender));
    }
}
}
