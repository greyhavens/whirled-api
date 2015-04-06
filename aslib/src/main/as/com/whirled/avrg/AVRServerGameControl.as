//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import flash.utils.Dictionary;

import com.threerings.util.Log;

import com.whirled.AbstractControl;
import com.whirled.ServerObject;
import com.whirled.net.PropertySubControl;
import com.whirled.net.impl.PropertySubControlImpl;
import com.whirled.avrg.AVRGameControlEvent;

/**
 * This file should be included by the server agents of AVR games so that they can communicate
 * with the whirled. Server agents are normally responsible for deciding how players will be
 * grouped and for an arbitrary amount of the game logic.
 *
 * <p>AVRGame means: Alternate Virtual Reality Game, and refers to games played within the whirled
 * environment with your avatar.</p>
 *
 * <p>AVR games can be significantly more complicated than lobbied games. Please consult the whirled
 * wiki section on AVRGs as well as the AVRG discussion forum if you're having any problems.</p>
 *
 * @see http://wiki.whirled.com/AVR_Games
 * @see http://www.whirled.com/#whirleds-d_135
 */
public class AVRServerGameControl extends AbstractControl
{
    /**
     * Creates a new game control for a server agent.
     */
    public function AVRServerGameControl (serv :ServerObject)
    {
        super(serv);
    }

    /**
     * Accesses the private properties for the server agent: these are not distributed to any
     * clients and can thus be updated with greater frequency than the game-global ones.
     *
     * Properties marked as such will be persisted and restored whenever the server agent starts.
     *
     * @see com.whirled.net.NetConstants#makePersistent()
     */
    public function get props () :PropertySubControl
    {
        return _props;
    }

    /**
     * Accesses the server agent's game sub control.
     */
    public function get game () :GameSubControlServer
    {
        return _game;
    }

    /**
     * Accesses the server agent's room sub control for a given room id. This method will fail by
     * throwing an <code>Error</code> if the room is not currently loaded by the server agent. A
     * room with at least one player in it is guaranteed to be loaded. Server agents are notified
     * of player entry and exit by events. A room with no players in it should be considered
     * unloaded after the event is sent for the last player exiting the room.
     * @see AVRGamePlayerEvent#ENTERED_ROOM
     * @see AVRGamePlayerEvent#LEFT_ROOM
     * @see AVRGameRoomEvent#PLAYER_ENTERED
     * @see AVRGameRoomEvent#PLAYER_LEFT
     */
    public function getRoom (roomId :int) :RoomSubControlServer
    {
        var ctrl :RoomSubControlServer = _roomControls[roomId];
        if (ctrl == null) {
            // This throws an error if the room isn't loaded
            ctrl = new RoomSubControlServer(this, roomId);
            ctrl.gotHostProps(_funcs);
            _roomControls[roomId] = ctrl;
        }
        return ctrl;
    }

    /**
     * Accesses the server agent's player sub control for a player with a given id. Server agents
     * are notified when a player joins and quits the game by events. An <code>Error</code> is
     * thrown if the requested player has not joined the game or has quit.
     * @see AVRGameControlEvent.PLAYER_JOINED
     * @see AVRGameControlEvent.PLAYER_QUIT
     */
    public function getPlayer (playerId :int) :PlayerSubControlServer
    {
        var ctrl :PlayerSubControlServer = _playerControls[playerId];
        if (ctrl == null) {
            // This throws an error if the player isn't loaded
            ctrl = new PlayerSubControlServer(this, playerId);
            ctrl.gotHostProps(_funcs);
            _playerControls[playerId] = ctrl;
        }
        return ctrl;
    }

    /**
     * Loads the property space of an offline player and calls your function with it as an
     * argument. Within this callback, you may read and write persistent properties as you
     * see fit. Note: To preserve some semblance of sanity, you can only load the properties
     * of a player who has already had at least one persistent property set.
     *
     * @example An example, whereby one player may leave an offline message for another player:
     * <listing version="3.0">
     *    _ctrl.loadOfflinePlayer(opponentPlayerId, function (props :PropertySubControl) :void {
     *        props.setIn("messages", myPlayerId, myMessage);
     *    }, function (failureCause :String) :void {
     *        log.warn("Eek! Sending message to offline player failed!", "cause", failureCause);
     *   });
     * </listing>
     */
    public function loadOfflinePlayer (playerId :int, success :Function, failure :Function) :void
    {
        var thisControl :AbstractControl = this;

        callHostCode("loadOfflinePlayer_v1", playerId, function (props :Object) :void {
            success(new OfflinePlayerPropertyControl(thisControl, playerId, props));
        }, failure);
    }

    /** @private */
    override public function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["playerLeft_v1"] = relayTo(getRoom, "playerLeft_v1");
        o["playerEntered_v1"] = relayTo(getRoom, "playerEntered_v1");
        o["actorStateSet_v1"] = relayTo(getRoom, "actorStateSet_v1");
        o["actorAppearanceChanged_v1"] = relayTo(getRoom, "actorAppearanceChanged_v1");
        o["playerMoved_v1"] = relayTo(getRoom, "playerMoved_v1");

        o["mobSpawned_v1"] = relayTo(getRoom, "mobSpawned_v1");
        o["mobRemoved_v1"] = relayTo(getRoom, "mobRemoved_v1");
        o["mobAppearanceChanged_v1"] = relayTo(getRoom, "mobAppearanceChanged_v1");

        o["signalReceived_v1"] = relayTo(getRoom, "signalReceived_v1");
        o["musicStartStop_v1"] = relayTo(getRoom, "musicStartStop_v1");

        o["leftRoom_v1"] = relayTo(getPlayer, "leftRoom_v1");
        o["enteredRoom_v1"] = relayTo(getPlayer, "enteredRoom_v1");
        o["taskCompleted_v1"] = relayTo(getPlayer, "taskCompleted");
        o["player_propertyWasSet_v1"] = relayTo(getPlayerProps, "propertyWasSet_v1");

        o["roomUnloaded_v1"] = roomUnloaded_v1;

        o["playerJoinedGame_v1"] = playerJoinedGame_v1;
        o["playerLeftGame_v1"] = playerLeftGame_v1;

        o["notifyGameContentAdded_v1"] = notifyGameContentAdded_v1;
        o["notifyGameContentConsumed_v1"] = notifyGameContentConsumed_v1;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            _props = new PropertySubControlImpl(
                this, 0, "agent_getGameData_v1", "agent_setProperty_v1"),
            _game = new GameSubControlServer(this),
        ];
    }

    /** @private */
    protected function getPlayerProps (playerId :int) :PropertySubControl
    {
        return getPlayer(playerId).props;
    }

    /** @private */
    protected function playerJoinedGame_v1 (playerId :int) :void
    {
        game.dispatchEvent(new AVRGameControlEvent(
            AVRGameControlEvent.PLAYER_JOINED_GAME, null, playerId));
    }

    /** @private */
    protected function playerLeftGame_v1 (playerId :int) :void
    {
        game.dispatchEvent(new AVRGameControlEvent(
            AVRGameControlEvent.PLAYER_QUIT_GAME, null, playerId));
        delete _playerControls[playerId];
    }

    /** @private */
    protected function relayTo (getObj :Function, fun :String) :Function
    {
        return function (targetId :int, ... args) :* {
            // fetch the relevant subcontrol
            var obj :Object = getObj(targetId);
            // early-development sanity checks
            if (obj == null) {
                throw new Error("failed to find subcontrol [targetId=" + targetId + "]");
            }
            if (obj[fun] == null) {
                throw new Error("failed to find function in subcontrol [targetId=" +
                                targetId + ", fun=" + fun + "]");
            }
            // call the right function on it
            return obj[fun].apply(obj, args);
        };
    }

    /**
     * Called by the backend when a room is no longer accessible.
     * @private
     */
    protected function roomUnloaded_v1 (roomId :int) :void
    {
        var ctrl :RoomSubControlServer = (_roomControls[roomId] as RoomSubControlServer);
        if (ctrl != null) {
            ctrl.roomUnloaded_v1();
            delete _roomControls[roomId];
        }
    }

    private function notifyGameContentAdded_v1 (type :String, ident :String, playerId :int) :void
    {
        getPlayer(playerId).notifyGameContentAdded_v1(type, ident, playerId);
    }

    private function notifyGameContentConsumed_v1 (type :String, ident :String, playerId :int) :void
    {
        getPlayer(playerId).notifyGameContentConsumed_v1(type, ident, playerId);
    }

    /** @private */
    protected var _game :GameSubControlServer;

    /** @private */
    protected var _roomControls :Dictionary = new Dictionary();

    /** @private */
    protected var _playerControls :Dictionary = new Dictionary();

    /** @private */
    protected var _props :PropertySubControlImpl;
}
}

