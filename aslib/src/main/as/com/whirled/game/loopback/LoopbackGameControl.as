//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.loopback {

import com.threerings.util.ArrayUtil;
import com.threerings.util.DelayUtil;
import com.threerings.util.Integer;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.ObjectMarshaller;
import com.threerings.util.Set;
import com.threerings.util.Sets;
import com.threerings.util.StringUtil;
import com.threerings.util.Util;
import com.whirled.game.CoinsAwardedEvent;
import com.whirled.game.GameContentEvent;
import com.whirled.game.GameControl;
import com.whirled.game.LobbyClosedEvent;
import com.whirled.game.SizeChangedEvent;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.UserChatEvent;
import com.whirled.game.client.PropertySpaceHelper;

import flash.display.DisplayObject;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.setTimeout;

public class LoopbackGameControl extends GameControl
{
    public function LoopbackGameControl (disp :DisplayObject,
                                         isServer :Boolean,
                                         isPartyGame :Boolean,
                                         autoReady :Boolean = true,
                                         completelyOffline :Boolean = false)
    {
        _disp = disp;
        _isPartyGame = isPartyGame;

        // Instantiate a real connection to Whirled, to forward certain requests to?
        if (_whirledCtrl == null && !completelyOffline) {
            var ctrl :GameControl = new GameControl(disp, false);
            if (ctrl.isConnected()) {
                _whirledCtrl = ctrl;
            }
        }

        if (isServer) {
            _serverLoopback = this;
            _serverAgentId = SERVER_AGENT_ID;
        } else {
            _playerLoopback = this;
            _playerId = (_whirledCtrl != null ? _whirledCtrl.game.getMyId() : 1);
        }

        _disp.root.loaderInfo.sharedEvents.addEventListener(
            "controlConnect", handleUserCodeConnect, false, int.MAX_VALUE);

        super(_disp, false);

        if (_whirledCtrl != null) {
            // If we're connected to whirled, we'll route a handful of requests to whirled,
            // and route a handful of events back to the game
            redispatch(SizeChangedEvent.SIZE_CHANGED, _whirledCtrl.local, this.local);
            redispatch(LobbyClosedEvent.LOBBY_CLOSED, _whirledCtrl.local, this.local);

            redispatch(CoinsAwardedEvent.COINS_AWARDED, _whirledCtrl.player, this.player);
            redispatch(GameContentEvent.PLAYER_CONTENT_ADDED, _whirledCtrl.player, this.player);
            redispatch(GameContentEvent.PLAYER_CONTENT_CONSUMED, _whirledCtrl.player, this.player);

            redispatch(StateChangedEvent.GAME_STARTED, _whirledCtrl.game, this.game);
            redispatch(StateChangedEvent.GAME_ENDED, _whirledCtrl.game, this.game);
            redispatch(UserChatEvent.USER_CHAT, _whirledCtrl.game, this.game);
        }

        if (autoReady && this.isPlayer) {
            callHostCode("playerReady_v1");
        }
    }

    protected function redispatch (eventType :String, source :EventDispatcher,
        target :EventDispatcher) :void
    {
        source.addEventListener(eventType,
            function (e :Event) :void {
                target.dispatchEvent(e);
            });
    }

    /**
     * Handle any shutdown required.
     */
    override protected function handleUnload (event :Event) :void
    {
        stopAllTickers();
        super.handleUnload(event);
    }

    override public function isConnected () :Boolean
    {
        // Always connected
        return true;
    }

    // From here we act like Base
    protected function handleUserCodeConnect (evt :Event) :void
    {
        evt.stopImmediatePropagation();

        // Unsubscribe from this event now. We may be running the server locally, and it
        // will also be listening for the event.
        _disp.root.loaderInfo.sharedEvents.removeEventListener(
            "controlConnect", handleUserCodeConnect);

        // Do everything that BaseGameBackend does
        var props :Object = Object(evt).props;

        var userProps :Object = props.userProps;
        setUserCodeProperties(userProps);

        var ourProps :Object = new Object();
        populateProperties(ourProps);
        props["hostProps"] = ourProps;
    }

    protected function setUserCodeProperties (o :Object) :void
    {
        // here we would handle adapting old functions to a new version
        _userFuncs = o;

        // here we would handle adapting old functions to a new version
        _keyDispatcher = (o["dispatchEvent_v1"] as Function);
    }

    protected function callUserCode (name :String, ... args) :*
    {
        if (_userFuncs != null) {
            try {
                var func :Function = (_userFuncs[name] as Function);
                if (func != null) {
                    return func.apply(null, args);
                }

            } catch (err :Error) {
                reportGameError("Error in user-code: " + err, err);
            }
        }
        return undefined;
    }

    protected function populateProperties (o :Object) :void
    {
        /* BaseGameBackend */

        // straight data
        o["gameData"] = _gameData;

        // convert our game config from a HashMap to a Dictionary
        /*var gameConfig :Object = {};
        var cfg :BaseGameConfig = getConfig();
        cfg.params.forEach(function (key :Object, value :Object) :void {
            gameConfig[key] = (value is Boxed) ? Boxed(value).unbox() : value;
        });
        o["gameConfig"] = gameConfig;
        o["gameInfo"] = createGameInfo();*/

        // GameControl
        routeFunction(o, "commitTransaction", commitTransaction_v1, false);
        routeFunction(o, "startTransaction", startTransaction_v1, false);

        // .net
        routeFunction(o, "sendMessage_v2", sendMessage_v2, false);
        routeFunction(o, "setProperty_v2", setProperty_v2, false);
        routeFunction(o, "testAndSetProperty_v1", testAndSetProperty_v1, false);

        // .player
        routeFunction(o, "getUserCookie_v2", getUserCookie_v2, true);
        routeFunction(o, "getCookie_v1", getCookie_v1, true);
        routeFunction(o, "setUserCookie_v1", setUserCookie_v1, true);
        routeFunction(o, "setCookie_v1", setCookie_v1, true);
        routeFunction(o, "holdsTrophy_v1", holdsTrophy_v1, true);
        routeFunction(o, "awardTrophy_v1", awardTrophy_v1, true);
        routeFunction(o, "awardPrize_v1", awardPrize_v1, true);
        routeFunction(o, "getPlayerItemPacks_v1", getPlayerItemPacks_v1, true);
        routeFunction(o, "getPlayerLevelPacks_v1", getPlayerLevelPacks_v1, true);
        routeFunction(o, "requestConsumeItemPack_v1", requestConsumeItemPack_v1, true);

        // .game
        routeFunction(o, "endGame_v2", endGame_v2, true);
        routeFunction(o, "endGameWithScores_v1", endGameWithScores_v1, true);
        routeFunction(o, "endGameWithWinners_v1", endGameWithWinners_v1, true);
        routeFunction(o, "endRound_v1", endRound_v1, false);
        routeFunction(o, "getRound_v1", getRound_v1, false);
        routeFunction(o, "getTurnHolder_v1", getTurnHolder_v1, false);
        routeFunction(o, "isInPlay_v1", isInPlay_v1, true);
        routeFunction(o, "restartGameIn_v1", restartGameIn_v1, true);
        routeFunction(o, "startNextTurn_v1", startNextTurn_v1, false);
        routeFunction(o, "getControllerId_v1", getControllerId_v1, false);
        routeFunction(o, "getLevelPacks_v2", getLevelPacks_v2, true);
        routeFunction(o, "getItemPacks_v1", getItemPacks_v1, true);
        routeFunction(o, "loadLevelPackData_v1", loadLevelPackData_v1, true);
        routeFunction(o, "loadItemPackData_v1", loadItemPackData_v1, true);
        routeFunction(o, "getOccupants_v1", getOccupants_v1, false);
        routeFunction(o, "getOccupantName_v1", getOccupantName_v1, false);
        routeFunction(o, "sendChat_v1", sendChat_v1, true);
        routeFunction(o, "getMyId_v1", getMyId_v1, false);

        // .game.seating
        routeFunction(o, "getPlayers_v1", getPlayers_v1, false);
        routeFunction(o, "getPlayerPosition_v1", getPlayerPosition_v1, false);
        routeFunction(o, "getMyPosition_v1", getMyPosition_v1, false);

        // .services
        routeFunction(o, "checkDictionaryWord_v2", checkDictionaryWord_v2, true);
        routeFunction(o, "getDictionaryLetterSet_v2", getDictionaryLetterSet_v2, true);
        routeFunction(o, "getDictionaryWords_v1", getDictionaryWords_v1, true);
        routeFunction(o, "setTicker_v1", setTicker_v1, false);

        // .services.bags
        routeFunction(o, "getFromCollection_v2", getFromCollection_v2, false);
        routeFunction(o, "mergeCollection_v1", mergeCollection_v1, false);
        routeFunction(o, "populateCollection_v1", populateCollection_v1, false);

        // Old methods: backwards compatability
        //routeFunction(o, "awardFlow_v1", awardFlow_v1, false);
        //routeFunction(o, "awardFlow_v2", awardFlow_v2, false);
        //routeFunction(o, "checkDictionaryWord_v1", checkDictionaryWord_v1, false);
        //routeFunction(o, "endTurn_v2", startNextTurn_v1, false); // it's the same!
        //routeFunction(o, "getAvailableFlow_v1", getAvailableFlow_v1, false);
        //routeFunction(o, "getDictionaryLetterSet_v1", getDictionaryLetterSet_v1, false);
        //routeFunction(o, "setProperty_v1", setProperty_v1, false);
        //routeFunction(o, "getLevelPacks_v1", getLevelPacks_v1, false);

        /* WhirledGameBackend */

        // GameControl
        routeFunction(o, "focusContainer_v1", focusContainer_v1, true);

        // .local
        routeFunction(o, "alterKeyEvents_v1", alterKeyEvents_v1, true);
        routeFunction(o, "clearScores_v1", clearScores_v1, true);
        routeFunction(o, "filter_v1", filter_v1, true);
        routeFunction(o, "getHeadShot_v2", getHeadShot_v2, true);
        routeFunction(o, "getSize_v1", getSize_v1, true);
        routeFunction(o, "isEmbedded_v1", isEmbedded_v1, true);
        routeFunction(o, "localChat_v1", localChat_v1, true);
        routeFunction(o, "setMappedScores_v1", setMappedScores_v1, true);
        routeFunction(o, "setOccupantsLabel_v1", setOccupantsLabel_v1, true);
        routeFunction(o, "setPlayerScores_v1", setPlayerScores_v1, true);
        routeFunction(o, "setFrameRate_v1", setFrameRate_v1, true);
        routeFunction(o, "setShowReplay_v1", setShowReplay_v1, true);
        routeFunction(o, "setStageQuality_v1", setStageQuality_v1, true);
        routeFunction(o, "showAllGames_v1", showAllGames_v1, true);
        routeFunction(o, "showGameLobby_v1", showGameLobby_v1, true);
        routeFunction(o, "showGameShop_v1", showGameShop_v1, true);
        routeFunction(o, "showTrophies_v1", showTrophies_v1, true);
        routeFunction(o, "showInvitePage_v1", showInvitePage_v1, true);
        routeFunction(o, "getInviteToken_v1", getInviteToken_v1, true);
        routeFunction(o, "getInviterMemberId_v1", getInviterMemberId_v1, true);

        // .game
        routeFunction(o, "isMyTurn_v1", isMyTurn_v1, false);
        routeFunction(o, "playerReady_v1", playerReady_v1, true);

        // Old methods: backwards compatability
        //routeFunction(o, "getStageBounds_v1", getStageBounds_v1, false);
        //routeFunction(o, "getHeadShot_v1", getHeadShot_v1, false);
        //routeFunction(o, "setShowButtons_v1", setShowButtons_v1, false);
    }

    protected function routeFunction (o :Object, name :String, offlineImpl :Function,
        rerouteToWhirled :Boolean) :void
    {
        var f :Function;
        if (rerouteToWhirled && _whirledCtrl != null) {
            f = function (...args) :* {
                args.unshift(name);
                return _whirledCtrl.callHostCode.apply(null, args);
            };
        } else {
            f = offlineImpl;
        }

        o[name] = f;
    }

    //---- GameControl -----------------------------------------------------

    /**
     * Starts a transaction that will group all game state changes into a single message.
     */
    protected function startTransaction_v1 () :void
    {
        // increment our transaction nesting count
        if (_transactionCount++ == 0) {
            _curTransaction = [];
        }
    }

    /**
     * Commits a transaction started with <code>startTransaction_v1</code>.
     */
    protected function commitTransaction_v1 () :void
    {
        if (_transactionCount <= 0) {
            throw new IllegalOperationError("Cannot commit: not involved in a transaction");
        }
        if (--_transactionCount == 0) {
            for each (var op :Function in _curTransaction) {
                DelayUtil.delayFrame(op);
            }

            _curTransaction = null;
        }
    }

    //---- .net ------------------------------------------------------------

    protected function sendMessage_v2 (messageName :String, value :Object, playerId :int) :void
    {
        validateName(messageName);
        validateValue(value);

        var messageOp :Function = function () :void {
            receiveMessage(messageName, value, getMyId_v1(), playerId);
        };

        if (_transactionCount > 0) {
            _curTransaction.push(messageOp);
        } else {
            DelayUtil.delayFrame(messageOp);
        }
    }

    protected static function receiveMessage (messageName :String, value :Object, fromId :int,
                                              toId :int) :void
    {
        if ((toId == TO_ALL || toId == _playerId) && _playerLoopback != null) {
            _playerLoopback.receiveMessageLocally(messageName, value, fromId);
        }

        if ((toId == TO_ALL || toId == SERVER_AGENT_ID) && _serverLoopback != null) {
            _serverLoopback.receiveMessageLocally(messageName, value, fromId);
        }
    }

    protected function receiveMessageLocally (messageName :String, value :Object, fromId :int) :void
    {
        callUserCode("messageReceived_v2", messageName, value, fromId);
    }

    /**
     * Sets a property.
     *
     * Note: immediate defaults to true, even though immediate=false is the general case. We are
     * providing some backwards compatibility to old versions of setProperty_v1() that assumed
     * immediate and did not pass a 4th value.  All callers should now specify that value
     * explicitly.
     */
    protected function setProperty_v2 (
        propName :String, value :Object, key :Object, isArray :Boolean, immediate :Boolean) :void
    {
        validatePropertyChange(propName, value, isArray, int(key));

        var encoded :Object = PropertySpaceHelper.encodeProperty(value, (key == null));
        var ikey :Integer = (key == null) ? null : new Integer(int(key));
        if (immediate) {
            // we re-decode so that it looks like it came off the net
            try {
                applyPropertySet(
                    _gameData, propName, PropertySpaceHelper.decodeProperty(encoded), key, isArray);
            } catch (re :RangeError) {
                trace("Error setting property (immediate): " + re);
            }
        }

        var propOp :Function = function () :void {
            updateProp(propName, encoded, ikey, isArray);
        };

        if (_transactionCount > 0) {
            _curTransaction.push(propOp);
        } else {
            DelayUtil.delayFrame(propOp);
        }
    }

    /**
     * Test and set a property. Note that the 'index' parameter was deprecated on 2008-02-20.
     * Newer code will only pass in propName, value, testValue. Older code will also pass in the
     * index, but that's ok as long as it's -1.
     */
    protected function testAndSetProperty_v1 (
        propName :String, value :Object, testValue :Object, index :int = -1) :void
    {
        if (index != -1) {
            throw new Error("Sorry, using testAndSet with an index value is no longer supported. " +
                "Update your SDK.");
        }
        validatePropertyChange(propName, value, false, 0);

        var encodedValue :Object = PropertySpaceHelper.encodeProperty(value, true);
        var encodedTestValue :Object = PropertySpaceHelper.encodeProperty(testValue, true);

        var propOp :Function = function () :void {
            // If we're running a server, its game data is the "official" game data
            var officialData :Object =
                (_serverLoopback != null ? _serverLoopback._gameData : _gameData);

            // Encode the official value and compare it the test value
            var encodedCurValue :Object =
                PropertySpaceHelper.encodeProperty(officialData[propName], true);
            if (Util.equals(encodedTestValue, encodedCurValue)) {
                updateProp(propName, encodedValue, null, false);
            }
        };

        if (_transactionCount > 0) {
            _curTransaction.push(propOp);
        } else {
            DelayUtil.delayFrame(propOp);
        }
    }

    protected static function updateProp (propName :String, encodedVal :Object, ikey :Integer,
        isArray :Boolean) :void
    {
        if (_playerLoopback != null) {
            _playerLoopback.updatePropLocally(propName, encodedVal, ikey, isArray);
        }
        if (_serverLoopback != null) {
            _serverLoopback.updatePropLocally(propName, encodedVal, ikey, isArray);
        }
    }

    protected function updatePropLocally (propName :String, encodedVal :Object, ikey :Integer,
        isArray :Boolean) :void
    {
        var value :Object = PropertySpaceHelper.decodeProperty(encodedVal);
        var keyObj :Object = (ikey == null) ? null : ikey.value;
        var oldValue :Object;
        try {
            oldValue = applyPropertySet(_gameData, propName, value, keyObj, isArray);
        } catch (re :RangeError) {
            trace("Error setting property: " + re);
            return;
        }

        callUserCode("propertyWasSet_v2", propName, value, oldValue, keyObj);
    }

    //---- .player ---------------------------------------------------------

    protected function getUserCookie_v2 (playerId :int, callback :Function) :void
    {
        getCookie_v1(function (cookie :Object, ...unused) :void {
            callback(cookie);
        }, playerId);
    }

    protected function getCookie_v1 (callback :Function, occupantId :int) :void
    {
        if (occupantId == CURRENT_USER) {
            occupantId = getMyId_v1();
            if (occupantId == SERVER_AGENT_ID) {
                throw new Error("Server agent must provide a player id here");
            }
        }

        var cookieBytes :ByteArray = (_userCookies.get(occupantId) as ByteArray);
        var cookie :Object = (cookieBytes != null ? ObjectMarshaller.decode(cookieBytes) : null);
        callback(cookie, occupantId);
    }

    protected function setUserCookie_v1 (cookie :Object, playerId :int = CURRENT_USER) :Boolean
    {
        return setCookie_v1(cookie, playerId);
    }

    protected function setCookie_v1 (cookie :Object, occupantId :int = CURRENT_USER) :Boolean
    {
        validateValue(cookie);

        if (occupantId == CURRENT_USER) {
            occupantId = getMyId_v1();
            if (occupantId == SERVER_AGENT_ID) {
                throw new Error("Server agent must provide a player id here");
            }
        }

        var ba :ByteArray = (ObjectMarshaller.encode(cookie, false) as ByteArray);
        if (ba.length > MAX_USER_COOKIE) {
            // not saved!
            return false;
        }

        receiveUserCookie(occupantId, ba);
        if (this.otherLoopback != null) {
            this.otherLoopback.receiveUserCookie(occupantId, ba);
        }

        return true;
    }

    protected function receiveUserCookie (occupantId :int, cookieBytes :ByteArray) :void
    {
        _userCookies.put(occupantId, cookieBytes);
    }

    protected function holdsTrophy_v1 (ident :String, playerId :int = CURRENT_USER) :Boolean
    {
        if (playerId == CURRENT_USER) {
            playerId = getMyId_v1();
            if (playerId == SERVER_AGENT_ID) {
                throw new Error("Server agent must provide a player id here");
            }
        }

        if (playerId == _playerId && _playerLoopback != null) {
            return _playerLoopback._awardedTrophies.contains(ident);
        } else {
            return false;
        }
    }

    protected function awardTrophy_v1 (ident :String, playerId :int = CURRENT_USER) :Boolean
    {
        if (playerId == CURRENT_USER) {
            playerId = getMyId_v1();
            if (playerId == SERVER_AGENT_ID) {
                throw new Error("Server agent must provide a player id here");
            }
        }

        if (holdsTrophy_v1(ident, playerId)) {
            return false;
        }

        if (playerId == _playerId) {
            _playerLoopback._awardedTrophies.add(ident);
            return true;
        }

        return false;
    }

    protected function awardPrize_v1 (ident :String, playerId :int = CURRENT_USER) :void
    {
        // no-op
    }

    protected function getPlayerItemPacks_v1 (playerId :int = CURRENT_USER) :Array
    {
        // no-op
        return [];
    }

    protected function getPlayerLevelPacks_v1 (playerId :int = CURRENT_USER) :Array
    {
        // no-op
        return [];
    }

    protected function requestConsumeItemPack_v1 (ident :String, msg :String) :Boolean
    {
        // no-op
        return false;
    }

    //---- .game -----------------------------------------------------------

    protected function getTurnHolder_v1 () :int
    {
        return _turnHolderId;
    }

    protected function isMyTurn_v1 () :Boolean
    {
        return (getMyId_v1() == _turnHolderId);
    }

    protected function getRound_v1 () :int
    {
        return (_roundStarted ? _roundId : -_roundId);
    }

    protected function isInPlay_v1 () :Boolean
    {
        return _gameStarted;
    }

    protected function startNextTurn_v1 (nextPlayerId :int) :void
    {
        if (nextPlayerId != _playerId) {
            // TODO: what should we do here?
            return;
        }

        var turnOp :Function = function () :void {
            _turnHolderId = nextPlayerId;
            turnChanged();
            if (this.otherLoopback != null) {
                this.otherLoopback.turnChanged();
            }
        };

        DelayUtil.delayFrame(turnOp);
    }

    protected function turnChanged () :void
    {
        callUserCode("turnDidChange_v1");
    }

    protected function endRound_v1 (nextRoundDelay :int) :void
    {
        var startRoundOp :Function = function () :void {
            changeRoundState(true);
        };

        var endRoundOp :Function = function () :void {
            if (changeRoundState(false)) {
                // start the next round soon
                runOnce(Math.max(nextRoundDelay * 1000, 0), startRoundOp);
            }
        };

        DelayUtil.delayFrame(endRoundOp);
    }

    protected function changeRoundState (newState :Boolean) :Boolean
    {
        if (_gameStarted && _roundStarted != newState) {
            _roundStarted = newState;
            if (_roundStarted) {
                _roundId++;
            }

            roundStateChanged();
            if (this.otherLoopback != null) {
                this.otherLoopback.roundStateChanged();
            }

            return true;

        } else if (_gameStarted && _roundStarted == newState) {
            reportGameError(newState ? "Failed to start round; round already started" :
                                       "Failed to end round; round already ended");
        } else if (!_gameStarted) {
            reportGameError("Failed to start or end a round; the game is not in play");
        }

        return false;
    }

    protected function roundStateChanged () :void
    {
        callUserCode("roundStateChanged_v1", _roundStarted);
    }

    protected function endGame_v2 (... winnerIds) :void
    {
        var loserIds :Array = [];
        if (!ArrayUtil.contains(winnerIds, _playerId)) {
            loserIds.push(_playerId);
        }

        endGameWithWinners_v1(winnerIds, loserIds, 0) // WhirledGameControl.CASCADING_PAYOUT
    }

    protected function endGameWithWinners_v1 (
        winnerIds :Array, loserIds :Array, payoutType :int) :void
    {
        var endGameOp :Function = function () :void {
            changeGameState(false, ArrayUtil.contains(winnerIds, _playerId), payoutType);
        };

        DelayUtil.delayFrame(endGameOp);
    }

    // gameMode was added on Oct-23-2008, most games will continue to use the default mode, but new
    // games may pass a non-zero value to make use of per-mode score distributions
    protected function endGameWithScores_v1 (playerIds :Array, scores :Array /* of int */,
        payoutType :int, gameMode :int = 0) :void
    {
        var endGameOp :Function = function () :void {
            var loopbackPlayerIdx :int = playerIds.indexOf(_playerId);
            var loopbackPlayerScore :int;
            if (loopbackPlayerIdx >= 0 && loopbackPlayerIdx < scores.length) {
                loopbackPlayerScore = scores[loopbackPlayerScore];
            }

            changeGameState(false, loopbackPlayerScore > 0, payoutType, gameMode);
        };

        DelayUtil.delayFrame(endGameOp);
    }

    protected function restartGameIn_v1 (seconds :int) :void
    {
        if (!_isPartyGame) {
            // I'd like to throw an error, but some old games incorrectly call this
            // and we don't want to break them, so just log it here, but we throw an Error
            // in newer versions of GameSubControl.
            reportGameError("restartGameIn() is only applicable to party games.");
            return;
        }

        var restartOp :Function = function () :void {
            runOnce(seconds * 1000,
                function () :void {
                    changeGameState(true);
                });
        };

        DelayUtil.delayFrame(restartOp);
    }

    /**
     * Called by the client code when it is ready for the game to be started (if called before the
     * game ever starts) or rematched (if called after the game has ended).
     */
    protected function playerReady_v1 () :void
    {
        if (_isPartyGame) {
            // I'd like to throw an error, but some old games incorrectly call this
            // and we don't want to break them, so just log it here, but we throw an Error
            // in newer versions of GameSubControl.
            reportGameError("playerReady() is only applicable to seated games.");
            return;
        }

        if (this.isPlayer) {
            var startOp :Function = function () :void {
                changeGameState(true);
            };

            DelayUtil.delayFrame(startOp);
        }
    }

    protected function changeGameState (newState :Boolean, loopbackPlayerIsWinner :Boolean = false,
                                        payoutType :int = 0, gameMode :int = 0) :void
    {
        if (_gameStarted != newState) {
            _gameStarted = newState;
            if (!_gameStarted) {
                // All tickers get stopped when the game ends
                stopAllTickers();

                if (loopbackPlayerIsWinner) {
                    // TODO - dispatch a flow award here or something?
                }
            }

            gameStateChanged();
            if (this.otherLoopback != null) {
                this.otherLoopback.gameStateChanged();
            }

        } else {
            reportGameError(newState ? "Failed to start game; game already started" :
                                       "Failed to end game; game already ended");
        }
    }

    protected function gameStateChanged () :void
    {
        callUserCode("gameStateChanged_v1", _gameStarted);
    }

    protected function sendChat_v1 (msg :String) :void
    {
        validateChat(msg);

        var chatOp :Function = function () :void {
            if (_playerLoopback != null) {
                _playerLoopback.receiveChat(getMyId_v1(), msg);
            }
            if (_serverLoopback != null) {
                _serverLoopback.receiveChat(getMyId_v1(), msg);
            }
        };

        DelayUtil.delayFrame(chatOp);
    }

    protected function getLevelPacks_v2 (filter :Function = null) :Array
    {
        // no-op
        return [];
    }

    protected function getItemPacks_v1 (filter :Function = null) :Array
    {
        // no-op
        return [];
    }

    protected function loadLevelPackData_v1 (
        ident :String, onLoaded :Function, onFailure :Function) :void
    {
        if (onFailure != null) {
            onFailure(new Error("Unknown data pack: " + ident));
        }
    }

    protected function loadItemPackData_v1 (
        ident :String, onLoaded :Function, onFailure :Function) :void
    {
        if (onFailure != null) {
            onFailure(new Error("Unknown data pack: " + ident));
        }
    }

    protected function receiveChat (senderId :int, msg :String) :void
    {
        callUserCode("userChat_v1", senderId, msg);
    }

    protected function getControllerId_v1 () :int
    {
        return (_playerLoopback != null ? _playerId : 0);
    }

    protected function getOccupants_v1 () :Array
    {
        return (_playerLoopback != null ? [ _playerId ] : []);
    }

    protected function getOccupantName_v1 (playerId :int) :String
    {
        return (playerId == _playerId ? "Loopback Player" : null);
    }

    protected function getMyId_v1 () :int
    {
        return (this.isServer ? _serverAgentId : _playerId);
    }

    protected function focusContainer_v1 () :void
    {
        // no-op
    }

    //---- .game.seating ---------------------------------------------------

    protected function getPlayerPosition_v1 (playerId :int) :int
    {
        return (playerId == _playerId ? 0 : -1);
    }

    protected function getPlayers_v1 () :Array
    {
        return (_playerLoopback != null ? [ _playerId ] : []);
    }

    protected function getMyPosition_v1 () :int
    {
        return getPlayerPosition_v1(getMyId_v1());
    }

    //---- .services -------------------------------------------------------

    protected function setTicker_v1 (tickerName :String, msOfDelay :int) :void
    {
        validateName(tickerName);

        if (!_gameStarted) {
            reportGameError("Failed to start a ticker; a game is not in session");
            return;
        }

        if (msOfDelay == 0) {
            stopTicker(tickerName);
        } else {
            if (_tickers.size() >= MAX_TICKERS) {
                reportGameError("There are already " + MAX_TICKERS + " running");
            } else if (_tickers.containsKey(tickerName)) {
                reportGameError("A ticker named '" + tickerName + "' already exists");
            } else {
                var ticker :Ticker = new Ticker();
                ticker.timer = new Timer(Math.max(msOfDelay, MIN_TICKER_INTERVAL));
                ticker.name = tickerName;

                ticker.timer.addEventListener(TimerEvent.TIMER,
                    function (...ignored) :void {
                        tickerFired(ticker);
                    });

                ticker.timer.start();
                _tickers.put(tickerName, ticker);
            }
        }
    }

    protected function tickerFired (ticker :Ticker) :void
    {
        receiveMessage(ticker.name, ticker.tickCount, 0, TO_ALL);
        ticker.tickCount++;
    }

    protected function stopTicker (tickerName :String) :void
    {
        var ticker :Ticker = _tickers.remove(tickerName) as Ticker;
        if (ticker != null) {
            ticker.timer.stop();
        } else {
            reportGameError("No ticker named '" + tickerName + "' exists");
        }
    }

    protected function stopAllTickers () :void
    {
        if (_tickers.size() > 0) {
            _tickers.forEach(
                function (name :String, ticker :Ticker) :void {
                    ticker.timer.stop();
                });
            _tickers.clear();
        }
    }

    protected function getDictionaryLetterSet_v2 (
        locale :String, dictionary :String, count :int, callback :Function) :void
    {
        var dictOp :Function = function () :void {
            var letters :Array = [];
            for (var ii :int = 0; ii < count; ++ii) {
                var idx :int = Math.random() * DICTIONARY_LETTERS.length;
                letters.push(DICTIONARY_LETTERS[idx]);
            }

            callback(letters);
        };

        DelayUtil.delayFrame(dictOp);
    }

    protected function getDictionaryWords_v1 (
        locale :String, dictionary :String, count :int, callback :Function) :void
    {
        var dictOp :Function = function () :void {
            var words :Array = DICTIONARY_WORDS.slice();
            ArrayUtil.shuffle(words);
            if (count < words.length) {
                words.splice(count - 1);
            }

            callback(words);
        };

        DelayUtil.delayFrame(dictOp);
    }

    protected function checkDictionaryWord_v2 (
        locale :String, dictionary :String, word :String, callback :Function) :void
    {
        var dictOp :Function = function () :void {
            callback(word, ArrayUtil.contains(DICTIONARY_WORDS, word));
        };

        DelayUtil.delayFrame(dictOp);
    }

    //---- .services.bags --------------------------------------------------

    protected function mergeCollection_v1 (srcColl :String, intoColl :String) :void
    {
        validateName(srcColl);
        validateName(intoColl);

        var bagOp :Function = function () :void {
            var src :Array = getBag(srcColl, false);
            if (src != null) {
                // shuffle 'src' and append it to 'into'
                ArrayUtil.shuffle(src);
                var into :Array = getBag(intoColl, true);
                for each (var val :* in src) {
                    into.push(val);
                }

                // and delete 'src'
                destroyBag(srcColl);
            }
        };

        DelayUtil.delayFrame(bagOp);
    }

    /**
     * Helper method for setCollection and addToCollection.
     */
    protected function populateCollection_v1 (
        collName :String, values :Array, clearExisting :Boolean) :void
    {
        validateName(collName);
        if (values == null) {
            throw new ArgumentError("Collection values may not be null.");
        }
        validateValue(values);

        var bagOp :Function = function () :void {
            if (clearExisting) {
                destroyBag(collName);
            }

            var bag :Array = getBag(collName, true);
            for each (var val :* in values) {
                bag.push(val);
            }
        };

        DelayUtil.delayFrame(bagOp);
    }

    /**
     * Helper method for pickFromCollection and dealFromCollection.
     */
    protected function getFromCollection_v2 (
        collName :String, count :int, msgOrPropName :String, playerId :int,
        consume :Boolean, callback :Function) :void
    {
        validateName(collName);
        validateName(msgOrPropName);
        if (count < 1) {
            throw new ArgumentError("Must retrieve at least one element!");
        }

        var bagOp :Function = function () :void {
            // Pick elements from the bag
            var pickedElements :Array = [];
            var bag :Array = getBag(collName, false);
            if (bag != null) {
                for (var ii :int = 0; ii < count; ++ii) {
                    if (bag.length == 0) {
                        break;
                    }
                    var idx :int = Math.random() * bag.length;
                    pickedElements.push(bag[idx]);
                    if (consume) {
                        bag.splice(idx, 1);
                    }
                }
            }

            // Send those elements in a message, or put them in a property
            var encoded :Object = PropertySpaceHelper.encodeProperty(pickedElements, true);
            if (playerId == TO_ALL) {
                updateProp(msgOrPropName, encoded, null, false);
            } else {
                receiveMessage(msgOrPropName, encoded, 0, playerId);
            }

            // If we have a callback, call it with the number of elements retrieved
            if (callback != null) {
                callback(pickedElements.length);
            }
        };

        DelayUtil.delayFrame(bagOp);
    }

    protected function getBag (name :String, create :Boolean) :Array
    {
        var bag :Array = _bags.get(name);
        if (bag == null && create) {
            bag = [];
            _bags.put(name, bag);
        }

        return bag;
    }

    protected function destroyBag (name :String) :void
    {
        _bags.remove(name);
    }

    //---- .local ----------------------------------------------------------

    protected function alterKeyEvents_v1 (keyEventType :String, add :Boolean) :void
    {
        if (add) {
            _disp.addEventListener(keyEventType, handleKeyEvent);
        } else {
            _disp.removeEventListener(keyEventType, handleKeyEvent);
        }
    }

    protected function localChat_v1 (msg :String) :void
    {
        validateChat(msg);
        // no-op
    }

    protected function filter_v1 (text :String) :String
    {
        // no-op
        return text;
    }

    protected function getHeadShot_v2 () :DisplayObject
    {
        // TODO
        return null;
    }

    /**
     * Get the size of the game area.
     */
    protected function getSize_v1 () :Point
    {
        return new Point(_disp.width, _disp.height);
    }

    protected function isEmbedded_v1 () :Boolean
    {
        return false;
    }

    protected function setShowReplay_v1 (show :Boolean) :void
    {
        // no-op
    }

    protected function setFrameRate_v1 (frameRate :Number, quality :String = null) :void
    {
        // then, let this throw whatever errors they might. Not our problem.
        _disp.stage.frameRate = Math.max(frameRate, 15);

        // NOTE: originally the quality was specified as the second argument to setFrameRate.
        // To preserve backwards compatibility, the quality arg is now optional, but if specified
        // we must still let it work.
        if (quality != null) {
            setStageQuality_v1(quality);
        }
    }

    protected function setStageQuality_v1 (quality :String) :void
    {
        // if quality is an invalid string, this might throw an error. Not our problem.
        _disp.stage.quality = quality;
    }

    protected function setOccupantsLabel_v1 (label :String) :void
    {
        // no-op
    }

    protected function clearScores_v1 (clearValue :Object = null,
        sortValuesToo :Boolean = false) :void
    {
        // no-op
    }

    protected function setPlayerScores_v1 (scores :Array, sortValues :Array = null) :void
    {
        // no-op
    }

    protected function setMappedScores_v1 (scores :Object) :void
    {
        // no-op
    }

    protected function showAllGames_v1 () :void
    {
        // no-op
    }

    protected function showGameShop_v1 (itemType :String, catalogId :int = 0) :void
    {
        // no-op
    }

    protected function showInvitePage_v1 (defmsg :String, token :String = "") :void
    {
        // no-op
    }

    protected function getInviteToken_v1 () :String
    {
        // no-op
        return null;
    }

    protected function getInviterMemberId_v1 () :int
    {
        // no-op
        return 0;
    }

    protected function showGameLobby_v1 (multiplayer :Boolean) :void
    {
        // no-op
    }

    protected function showTrophies_v1 () :void
    {
        // no-op
    }

    /**
     * Handle key events on our container and pass them into the game.
     */
    protected function handleKeyEvent (evt :Event) :void
    {
        // dispatch a cloned copy of the event, so that it's safe
        _keyDispatcher(evt.clone());
    }

    /**
     * Verify that the property name / value are valid.
     */
    protected function validatePropertyChange (
        propName :String, value :Object, array :Boolean, index :int) :void
    {
        validateName(propName);

        if (array) {
            if (index < 0) {
                throw new ArgumentError("Bogus array index specified.");
            }
            if (!(_gameData[propName] is Array)) {
                throw new ArgumentError("Property " + propName + " is not an Array.");
            }
        }

        // validate the value too
        validateValue(value);
    }

    /**
     * Verify that the specified name is valid.
     */
    protected function validateName (name :String) :void
    {
        if (name == null) {
            throw new ArgumentError("Property, message, and collection names must not be null.");
        }
    }

    /**
     * Verify that the supplied chat message is valid.
     */
    protected function validateChat (msg :String) :void
    {
        if (StringUtil.isBlank(msg)) {
            throw new ArgumentError("Empty chat may not be displayed.");
        }
    }

    /**
     * Verify that the value is legal to be streamed to other clients.
     */
    protected function validateValue (value :Object) :void
    {
        ObjectMarshaller.validateValue(value);
    }

    /**
     * Log the specified game error message.
     */
    protected function reportGameError (msg :String, err :Error = null) :void
    {
        // here, we just shoot this to the logs
        if (err != null) {
            log.warning(msg, err);
        } else {
            log.warning(msg);
        }
    }

    protected function get otherLoopback () :LoopbackGameControl
    {
        return (this == _playerLoopback ? _serverLoopback : _playerLoopback);
    }

    protected function runOnce (delayMs :Number, callback :Function) :void
    {
        // Flash docs say:
        // "If you do not call the clearTimeout() function to cancel the setTimeout() call,
        // the object containing the set timeout closure function will not be garbage collected."
        //
        // Let's assume that what they mean is that it won't be garbage collected *until
        // after the timeout is called* and hope we're right
        flash.utils.setTimeout(callback, delayMs);
    }

    protected function get isServer () :Boolean
    {
        return (this == _serverLoopback);
    }

    protected function get isPlayer () :Boolean
    {
        return !(this.isServer);
    }

    /**
     * Enacts a property change.
     * @return the old value
     *
     * @throws RangeError if the key is out of range (arrays only)
     */
    protected static function applyPropertySet (
        props :Object, propName :String, value :Object,
        key :Object, isArray :Boolean) :Object
    {
        var oldValue :Object = props[propName];
        if (key != null) {
            var index :int = int(key);
            if (isArray) {
                if (!(oldValue is Array)) {
                    throw new RangeError("Current value is not an Array.");
                }
                var arr :Array = (oldValue as Array);
                if (index < 0 || index >= arr.length) {
                    throw new RangeError("Array index out of range.");
                }
                oldValue = arr[index];
                arr[index] = value;

            } else {
                var dict :Dictionary = (oldValue as Dictionary);
                if (dict == null) {
                    dict = new Dictionary(); // force creation
                    props[propName] = dict;
                }
                oldValue = dict[index];
                if (value == null) {
                    delete dict[index];
                } else {
                    dict[index] = value;
                }
            }

        } else if (value != null) {
            // normal property set
            props[propName] = value;

        } else {
            // remove a property
            delete props[propName];
        }
        return oldValue;
    }

    protected var _disp :DisplayObject;

    protected var _userFuncs :Object;
    protected var _gameData :Object = new Object();

    protected var _userCookies :Map = Maps.newMapOf(String);
    protected var _awardedTrophies :Set = Sets.newSetOf(String);

    protected var _curTransaction :Array;
    protected var _transactionCount :int;

    /** The function on the GameControl which we can use to directly dispatch events to the
     * user's game. */
    protected var _keyDispatcher :Function;

    protected var log :Log = Log.getLog(this);

    protected static var _playerId :int;
    protected static var _serverAgentId :int;

    protected static var _isPartyGame :Boolean;
    protected static var _gameStarted :Boolean;
    protected static var _roundStarted :Boolean = true;
    protected static var _roundId :int;
    protected static var _turnHolderId :int;
    protected static var _tickers :Map = Maps.newMapOf(String); // Map<name:String, ticker:Ticker>
    protected static var _bags :Map = Maps.newMapOf(String); // Map<name:String, bag:Array>

    protected static var _playerLoopback :LoopbackGameControl;
    protected static var _serverLoopback :LoopbackGameControl;

    protected static var _whirledCtrl :GameControl;

    protected static const SERVER_AGENT_ID :int = int.MIN_VALUE;

    protected static const TO_ALL :int = 0;

    protected static const MAX_USER_COOKIE :int = 4096;

    protected static const CURRENT_USER :int = 0;

    protected static const MAX_TICKERS :int = 3;
    protected static const MIN_TICKER_INTERVAL :int = 50;

    protected static const DICTIONARY_LETTERS :Array = [
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
    ];

    protected static const DICTIONARY_WORDS :Array = [
        "the", "quick", "brown", "fox", "jumps", "over", "lazy", "dog"
    ];
}

}

import flash.utils.Timer;

class Ticker
{
    public var timer :Timer;
    public var name :String;
    public var tickCount :int;
}
