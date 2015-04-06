//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import flash.events.Event;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import com.threerings.util.Name;
import com.threerings.util.ObjectMarshaller;
import com.whirled.game.client.PropertySpaceHelper;
import com.whirled.game.data.PropertySpaceObject;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.TypedArray;

import com.threerings.presents.dobj.DSet;

import com.threerings.parlor.game.data.GameObject;
import com.threerings.parlor.turn.data.TurnGameObject;

public class WhirledGameObject extends GameObject
    implements TurnGameObject, PropertySpaceObject
{
    /** The identifier for a MessageEvent containing a user message. */
    public static const USER_MESSAGE :String = "Umsg";

    /** The identifier for a MessageEvent containing a user message. */
    public static const USER_MESSAGE_EXCLUDE_AGENT :String = "UmsgEA";

    /** The identifier for a MessageEvent containing game-system chat. */
    public static const GAME_CHAT :String = "Uchat";

    /** The identifier for a MessageEvent containing ticker notifications. */
    public static const TICKER :String = "Utick";

    /** A message dispatched to each player's client object when coins are awarded. */
    public static const COINS_AWARDED_MESSAGE :String = "CoinsAwarded";

    /** Value of <code>agentState</code> when the agent is launched but not yet running. */
    public static const AGENT_PENDING :int = 0;
    
    /** Value of <code>agentState</code> when everything is set to go. */
    public static const AGENT_READY :int = 1;
    
    /** Value of <code>agentState</code> when the could not be launched for some reason. */
    public static const AGENT_FAILED :int = 2;

    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>roundId</code> field. */
    public static const ROUND_ID :String = "roundId";

    /** The field name of the <code>controllerId</code> field. */
    public static const CONTROLLER_ID :String = "controllerId";

    /** The field name of the <code>turnHolder</code> field. */
    public static const TURN_HOLDER :String = "turnHolder";

    /** The field name of the <code>userCookies</code> field. */
    public static const USER_COOKIES :String = "userCookies";

    /** The field name of the <code>agentState</code> field. */
    public static const AGENT_STATE :String = "agentState";

    /** The field name of the <code>whirledGameService</code> field. */
    public static const WHIRLED_GAME_SERVICE :String = "whirledGameService";
    // AUTO-GENERATED: FIELDS END

    /** The current round id for this game. Rounds divide a single gameplay session into smaller
     * units. */
    public var roundId :int;

    /** The client that is in control of this game. The first client to enter will be assigned
     * control and control will subsequently be reassigned if that client disconnects or leaves. */
    public var controllerId :int;

    /** The current turn holder. */
    public var turnHolder :Name;

    /** A set of loaded user cookies. */
    public var userCookies :DSet;

    /** The set of game data available to this game. */
    public var gameData :TypedArray /* of GameData */;

    /** The current state of the game's agent, one of <code>AGENT_PENDING</code>, 
     * <code>AGENT_READY</code> or <code>AGENT_FAILED</code>. */
    public var agentState :int;

    /** Provides game related services. */
    public var whirledGameService :WhirledGameMarshaller;

    /** Provides game content related services. */
    public var contentService :ContentMarshaller;

    /** Provides prize and trophy related services. */
    public var prizeService :PrizeMarshaller;
    
    /** Provides property related services. */
    public var propertyService :PropertySpaceMarshaller;

    /** Provides messaging services. */
    public var messageService :WhirledGameMessageMarshaller;

    // from PropertySpaceObject
    public function getUserProps () :Object
    {
        return _props;
    }

    // from PropertySpaceObject
    public function getPropService () :PropertySpaceMarshaller
    {
        return propertyService;
    }

    // from TurnGameObject
    public function getTurnHolderFieldName () :String
    {
        return TURN_HOLDER;
    }

    // from TurnGameObject
    public function getTurnHolder () :Name
    {
        return turnHolder;
    }

    // from TurnGameObject
    public function getPlayers () :TypedArray /* of Name */
    {
        return players;
    }

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);

        // first read any regular bits
        readDefaultFields(ins);

        // then user properties
        PropertySpaceHelper.readProperties(this, ins);
    }

    /**
     * Reads the fields written by the default serializer for this instance.
     */
    protected function readDefaultFields (ins :ObjectInputStream) :void
    {
        roundId = ins.readInt();
        controllerId = ins.readInt();
        turnHolder = Name(ins.readObject());
        userCookies = DSet(ins.readObject());
        gameData = TypedArray(ins.readObject());
        agentState = ins.readInt();
        whirledGameService = WhirledGameMarshaller(ins.readObject());
        contentService = ContentMarshaller(ins.readObject());
        prizeService = PrizeMarshaller(ins.readObject());
        propertyService = PropertySpaceMarshaller(ins.readObject());
        messageService = WhirledGameMessageMarshaller(ins.readObject());
    }
    
    /** The raw properties set by the game. */
    protected var _props :Object = new Object();
}
}
