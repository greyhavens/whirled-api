//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.utils.Dictionary;

import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.Name;

import com.threerings.presents.dobj.ElementUpdatedEvent;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.util.SafeSubscriber;
import com.threerings.presents.util.PresentsContext;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.parlor.game.data.GameObject;

import com.whirled.game.data.BaseGameConfig;
import com.whirled.game.data.ThaneGameConfig;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.WhirledGameOccupantInfo;
import com.whirled.game.data.WhirledPlayerObject;

/**
 * Manages the backend of the game on a thane client.
 */
public class ThaneGameBackend extends BaseGameBackend
{
    public function ThaneGameBackend (
        ctx :PresentsContext, gameObj :WhirledGameObject, ctrl :ThaneGameController)
    {
        super(ctx, gameObj);
        _ctrl = ctrl;

        // create players for everyone already known to be in the game
        for each (var info :OccupantInfo in getPlayerInfos()) {
            if (isInited(info)) {
                preparePlayer(info.bodyOid, infoToId(info), function () :void {});
            }
        }
    }

    public function getConnectListener () :Function
    {
        return handleUserCodeConnect;
    }

    /** @inheritDoc */ // from BaseGameBackend
    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        // .game
        o["takeOverPlayer_v1"] = takeOverPlayer_v1;

        // Party. TODO? If there were a TestThaneGameBackend, we'd put this there, but there
        // isn't so we put it here and let it get overridden in MsoyThaneGameBackend
        o["game_getPartyIds_v1"] = function () :Array { return [] };
        o["player_getPartyId_v1"] = function (playerId :int) :int { return 0 };
    }

    /** @inheritDoc */ // from BaseGameBackend
    override public function shutdown () :void
    {
        super.shutdown();

        for each (var playerId :int in _players.keys()) {
            clearPlayer(playerId, function () :void { /* noop */ });
        }
    }

    /** @inheritDoc */ // from BaseGameBackend
    override protected function getConfig () :BaseGameConfig
    {
        return _ctrl.getConfig();
    }

    //---- GameControl -----------------------------------------------------

    //---- .game -----------------------------------------------------------

    /** @inheritDoc */ // from BaseGameBackend
    override protected function getMyId_v1 () :int
    {
        validateConnected();
        return SERVER_AGENT_ID;
    }

    protected function takeOverPlayer_v1 (playerId :int) :void
    {
        validateConnected();
        _gameObj.whirledGameService.makePlayerAI(
            playerId, createLoggingConfirmListener("makePlayerAI"));
    }

    // --------------------------

    protected function getPlayer (playerId :int) :BodyObject
    {
        var player :Player = _players.get(playerId) as Player;
        return (player == null) ? null : player.bobj;
    }

    // from BaseGameBackend
    override protected function countPlayerData (type :int, ident :String, playerId :int) :int
    {
        if (playerId == CURRENT_USER) {
            throw new Error("Server agent has no current user");
        }

        var player :WhirledPlayerObject = getPlayer(playerId) as WhirledPlayerObject;
        if (player != null) {
            return player.countGameContent(getGameId(), type, ident);
        }

        // not found
        log.warning("Player not found", "playerId", playerId);
        return 0;
    }

    // from BaseGameBackend
    override protected function occupantAdded (info :OccupantInfo) :void
    {
        if (isPlayer(info.username)) {
            preparePlayer(info.bodyOid, infoToId(info), function () :void {
                doOccupantAdded(info);
            });

        } else {
            doOccupantAdded(info);
        }
    }

    // from BaseGameBackend
    override protected function occupantRemoved (info :OccupantInfo) :void
    {
        clearPlayer(info.bodyOid, function () :void {
            doOccupantRemoved(info);
        });
    }

    // from BaseGameBackend
    override protected function occupantRoleChanged (info :OccupantInfo, isPlayerNow :Boolean) :void
    {
        if (isPlayerNow) {
            preparePlayer(info.bodyOid, infoToId(info), function () :void {
                doOccupantRoleChanged(info, true);
            });

        } else {
            clearPlayer(info.bodyOid, function () :void {
                doOccupantRoleChanged(info, false);
            });
        }
    }

    // from BaseGameBackend
    override protected function readyToStart () :Boolean
    {
        if (!super.readyToStart()) {
            return false;
        }

        for each (var info :OccupantInfo in getPlayerInfos()) {
            if (getPlayer(infoToId(info)) == null) {
                return false;
            }
        }
        return true;
    }

    protected function preparePlayer (bodyOid :int, playerId :int, onReady :Function) :void
    {
        var self :ThaneGameBackend = this;
        var player :Player = new Player();
        player.subber = new SafeSubscriber(bodyOid, function (bobj :BodyObject) :void {
            player.bobj = bobj;
            player.clistener = new ContentListener(bodyOid, getGameId(), self);
            player.bobj.addListener(player.clistener);
            onReady();
        }, function (oid :int, error :Error) :void {
            log.warning("Failed to subscribe to player object", "oid", oid, "error", error)
        });
        player.subber.subscribe(_ctx.getDObjectManager());
        _players.put(playerId, player);
    }

    protected function clearPlayer (playerId :int, onClear :Function) :void
    {
        var player :Player = _players.remove(playerId);
        if (player == null ) {
            onClear(); // never were a player
            return;
        }

        player.subber.unsubscribe(_ctx.getDObjectManager());
        if (player.bobj != null) {
            player.bobj.removeListener(player.clistener);
            onClear(); // only call onClear if we were ready
        }
    }

    protected var _ctrl :ThaneGameController;
    protected var _players :Map = Maps.newMapOf(int);
}
}

import com.threerings.presents.util.SafeSubscriber;
import com.threerings.crowd.data.BodyObject;
import com.whirled.game.client.ContentListener;

class Player
{
    public var subber :SafeSubscriber;
    public var bobj :BodyObject;
    public var clistener :ContentListener;
}
