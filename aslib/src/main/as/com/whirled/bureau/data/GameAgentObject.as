//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.bureau.data.AgentObject;
import com.whirled.game.data.ThaneGameConfig;

/**
 * Dynamic object representing an game agent running in a bureau on the server.
 */
public class GameAgentObject extends AgentObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>gameOid</code> field. */
    public static const GAME_OID :String = "gameOid";

    /** The field name of the <code>config</code> field. */
    public static const CONFIG :String = "config";
    // AUTO-GENERATED: FIELDS END

    /** The id of the game that this object is for. */
    public var gameOid :int;

    /** The configuration of the game (matches the WhirledGameConfig chosen by a flash client). */
    public var config :ThaneGameConfig;

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>gameOid</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public function setGameOid (value :int) :void
    {
        var ovalue :int = this.gameOid;
        requestAttributeChange(
            GAME_OID, value, ovalue);
        this.gameOid = value;
    }

    /**
     * Requests that the <code>config</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public function setConfig (value :ThaneGameConfig) :void
    {
        var ovalue :ThaneGameConfig = this.config;
        requestAttributeChange(
            CONFIG, value, ovalue);
        this.config = value;
    }
    // AUTO-GENERATED: METHODS END

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        gameOid = ins.readInt();
        config = ThaneGameConfig(ins.readObject());
    }
}
}
