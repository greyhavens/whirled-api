//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import flash.events.Event;

import com.whirled.AbstractControl;

import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.PropertyGetSubControlImpl;

import com.whirled.net.impl.PropertySubControlImpl;

/**
 * Dispatched when a new player joins the game. This event is guaranteed to be the first event
 * concerning a particular player during that player's session. It will normally be followed
 * immediately by a <code>ENTERED_ROOM</code> event.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.PLAYER_JOINED_GAME
 * @see com.whirled.avrg.AVRGamePlayerEvent#ENTERED_ROOM
 */
[Event(name="playerJoinedGame", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Dispatched when a player leaves the game. This event is guaranteed to be the last event
 * concerning a particular player during that player's session. Any requests related to the player
 * will fail after the player has quit. The event will normally be immediately preceded by a
 * <code>LEFT_ROOM</code> event.
 *
 * @eventType com.whirled.avrg.AVRGameControlEvent.PLAYER_QUIT_GAME
 * @see com.whirled.avrg.AVRGamePlayerEvent#LEFT_ROOM
 */
[Event(name="playerQuitGame", type="com.whirled.avrg.AVRGameControlEvent")]

/**
 * Provides services for AVR game server agents.
 * @see AVRServerGameControl#game
 */
public class GameSubControlServer extends GameSubControlBase
    implements MessageSubControl
{
    /** @private */
    public function GameSubControlServer (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    /**
     * Accesses the global properties for this game. Game properties marked as such will be
     * persisted  and restored whenever the server agent starts. Persistent properties should
     * only be used when genuinely necessary.
     *
     * @see com.whirled.net.NetConstants#makePersistent()
     */
    public function get props () :PropertySubControl
    {
        return _props;
    }

    /**
     * Sends a message to all players in this game. Use carefully since the resulting outgoing
     * message load could be significant. Games that overload the server are subject to
     * discretionary action. Players receive game messages by adding a listener to the
     * <code>GameSubControlClient</code>.
     * @see GameSubControlClient#event:MsgReceived
     */
    public function sendMessage (name :String, value :Object = null) :void
    {
        callHostCode("game_sendMessage_v1", name, value);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        _props = new PropertySubControlImpl(
            _parent, 0, "game_getGameData_v1", "game_setProperty_v1");
        return [ _props ];
    }

    /** @private */
    protected var _props :PropertySubControlImpl;
}
}
