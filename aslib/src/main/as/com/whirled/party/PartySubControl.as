//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.party {

import flash.events.Event;

import flash.display.DisplayObject;

import com.whirled.AbstractControl;
import com.whirled.TargetedSubControl;

/**
 * Dispatched when a player arrives in this party.
 *
 * @eventType com.whirled.party.PartySubControl.PLAYER_ENTERED_PARTY
 */
[Event(name="playerEnteredParty", type="com.whirled.ControlEvent")]

/**
 * Dispatched when a player leaves this party.
 *
 * @eventType com.whirled.party.PartySubControl.PLAYER_LEFT_PARTY
 */
[Event(name="playerLeftParty", type="com.whirled.ControlEvent")]

/**
 * Dispatched when the leader of the party changes.
 *
 * @eventType com.whirled.party.PartySubControl.PARTY_LEADER_CHANGED
 */
[Event(name="partyLeaderChanged", type="com.whirled.ControlEvent")]

/**
 * Provides services on a particular party.
 */
public class PartySubControl extends TargetedSubControl
{
    /**
     * An event type dispatched on the GameSubControl when a party joins the game.
     * <br/><b>name</b> - not used
     * <br/><b>value</b> - partyId
     *
     * @eventType partyEntered
     */
    public static const PARTY_ENTERED :String = "partyEntered";

    /**
     * An event type dispatched on the GameSubControl when a party leaves the game.
     * <br/><b>name</b> - not used
     * <br/><b>value</b> - partyId
     *
     * @eventType partyLeft
     */
    public static const PARTY_LEFT :String = "partyLeft";

    /**
     * An event type dispatched on a PartySubControl when a player joins that party.
     * <br/><b>name</b> - not used
     * <br/><b>value</b> - the playerId
     *
     * @eventType playerEnteredParty
     */
    public static const PLAYER_ENTERED_PARTY :String = "playerEnteredParty";

    /**
     * An event type dispatched on a PartySubControl when a player leaves that party.
     * <br/><b>name</b> - not used
     * <br/><b>value</b> - the playerId
     *
     * @eventType playerLeftParty
     */
    public static const PLAYER_LEFT_PARTY :String = "playerLeftParty";

    /**
     * An event type dispatched on a PartySubControl when the leader changes.
     * <br/><b>name</b> - not used
     * <br/><b>value</b> - the playerId of the new leader
     *
     * @eventType playerLeftParty
     */
    public static const PARTY_LEADER_CHANGED :String = "partyLeaderChanged";

    /** @private */
    public function PartySubControl (parent :AbstractControl, partyId :int)
    {
        super(parent, partyId);
    }

    /**
     * Get the party id, which is only used to identify a transient party instance. Parties
     * come and go. No permanent identification should be done with this id.
     * This method is a little redundant, because you need to know the id to get this control?
     */
    public function getPartyId () :int
    {
        return _targetId;
    }

    /**
     * Get the name of this party. This is not guaranteed to be unique.
     * If the party is no longer present, null will be returned.
     */
    public function getName () :String
    {
        return callHostCode("party_getName_v1");
    }

    /**
     * Get the group id of this party. Note that different parties could have the same group id.
     * If the party is no longer present, 0 will be returned.
     */
    public function getGroupId () :int
    {
        return callHostCode("party_getGroupId_v1");
    }

    /**
     * Get the name of the group hosting this party. The name should be considered changeable
     * and non-unique and only used for display purposes. The group id can be used for
     * identification of a group.
     * If the party is no longer present, null will be returned.
     */
    public function getGroupName () :String
    {
        return callHostCode("party_getGroupName_v1");
    }

    /**
     * Get the group logo, or null if called from the server agent.
     * If the party is no longer present, null will be returned.
     */
    public function getGroupLogo () :DisplayObject
    {
        return callHostCode("party_getGroupLogo_v1");
    }

    /**
     * Get the leaderId of this party.
     */
    public function getLeaderId () :int
    {
        return callHostCode("party_getLeaderId_v1");
    }

    /**
     * Get the player ids in this party that are in this place.
     * If the party is no longer present, an empty array will be returned.
     */
    public function getPlayerIds () :Array /* of int */
    {
        return callHostCode("party_getPlayerIds_v1");
    }

//    /**
//     * Attempt to move the entire party to a new room. You cannot make them appear to leave
//     * via exit coords.
//     *
//     * <p>Hard-wiring valid room ids should be avoided. Room ids can be obtained from properties
//     * stored by an admininstrative interface or from a server agent message containing currently
//     * active rooms.</p>
//     */
//    public function moveToRoom (roomId :int) :void
//    {
//        callHostCode("party_moveToRoom_v1", roomId);
//    }
}
}
