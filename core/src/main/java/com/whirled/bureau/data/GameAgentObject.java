package com.whirled.bureau.data;

import javax.annotation.Generated;
import com.threerings.bureau.data.AgentObject;
import com.whirled.game.data.ThaneGameConfig;

/**
 * Dynamic object representing an game agent running in a bureau on the server.
 */
public class GameAgentObject extends AgentObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>gameOid</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String GAME_OID = "gameOid";

    /** The field name of the <code>config</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String CONFIG = "config";
    // AUTO-GENERATED: FIELDS END

    /** The id of the game that this object is for. */
    public int gameOid;

    /** The configuration of the game (matches the WhirledGameConfig chosen by a flash client). */
    public ThaneGameConfig config;

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>gameOid</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setGameOid (int value)
    {
        int ovalue = this.gameOid;
        requestAttributeChange(
            GAME_OID, Integer.valueOf(value), Integer.valueOf(ovalue));
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
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setConfig (ThaneGameConfig value)
    {
        ThaneGameConfig ovalue = this.config;
        requestAttributeChange(
            CONFIG, value, ovalue);
        this.config = value;
    }
    // AUTO-GENERATED: METHODS END
}
