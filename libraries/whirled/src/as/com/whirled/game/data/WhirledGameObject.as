//
// $Id$

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

    /** The identifier for a MessageEvent containing game-system chat. */
    public static const GAME_CHAT :String = "Uchat";

    /** The identifier for a MessageEvent containing ticker notifications. */
    public static const TICKER :String = "Utick";

    /** A message dispatched to each player's client object when coins are awarded. */
    public static const COINS_AWARDED_MESSAGE :String = "CoinsAwarded";

    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>roundId</code> field. */
    public static const ROUND_ID :String = "roundId";

    /** The field name of the <code>controllerOid</code> field. */
    public static const CONTROLLER_OID :String = "controllerOid";

    /** The field name of the <code>turnHolder</code> field. */
    public static const TURN_HOLDER :String = "turnHolder";

    /** The field name of the <code>userCookies</code> field. */
    public static const USER_COOKIES :String = "userCookies";

    /** The field name of the <code>whirledGameService</code> field. */
    public static const WHIRLED_GAME_SERVICE :String = "whirledGameService";
    // AUTO-GENERATED: FIELDS END

    /** The current round id for this game. Rounds divide a single gameplay session into smaller
     * units. */
    public var roundId :int;

    /** The client that is in control of this game. The first client to enter will be assigned
     * control and control will subsequently be reassigned if that client disconnects or leaves. */
    public var controllerOid :int;

    /** The current turn holder. */
    public var turnHolder :Name;

    /** A set of loaded user cookies. */
    public var userCookies :DSet;

    /** The set of game data available to this game. */
    public var gameData :TypedArray /* of GameData */;

    /** The service interface for requesting special things from the server. */
    public var whirledGameService :WhirledGameMarshaller;

    // from PropertySpaceObject
    public function getUserProps () :Object
    {
        return _props;
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
        controllerOid = ins.readInt();
        turnHolder = (ins.readObject() as Name);
        userCookies = (ins.readObject() as DSet);
        gameData = (ins.readObject() as TypedArray);
        whirledGameService = (ins.readObject() as WhirledGameMarshaller);
    }
    
    /** The raw properties set by the game. */
    protected var _props :Object = new Object();
}
}
