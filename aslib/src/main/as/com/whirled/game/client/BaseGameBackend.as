//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.errors.IOError;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import com.threerings.io.TypedArray;

import com.threerings.util.Boxed;
import com.threerings.util.Integer;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.Name;
import com.threerings.util.ObjectMarshaller;
import com.threerings.util.StringUtil;
import com.threerings.util.Util;

import com.threerings.presents.client.ConfirmAdapter;
import com.threerings.presents.client.ResultAdapter;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_ResultListener;

import com.threerings.presents.dobj.ElementUpdateListener;
import com.threerings.presents.dobj.ElementUpdatedEvent;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.MessageAdapter;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.MessageListener;
import com.threerings.presents.dobj.SetListener;

import com.threerings.presents.util.PresentsContext;

import com.threerings.crowd.chat.client.ChatDisplay;
import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.crowd.chat.data.ChatMessage;
import com.threerings.crowd.chat.data.UserMessage;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.parlor.game.data.GameConfig;
import com.threerings.parlor.game.data.GameObject;
import com.threerings.parlor.game.data.UserIdentifier;

import com.whirled.game.GameContentEvent;
import com.whirled.game.client.PropertySpaceHelper;
import com.whirled.game.data.BaseGameConfig;
import com.whirled.game.data.GameData;
import com.whirled.game.data.ItemData;
import com.whirled.game.data.LevelData;
import com.whirled.game.data.PropertySetEvent;
import com.whirled.game.data.PropertySetListener;
import com.whirled.game.data.TrophyData;
import com.whirled.game.data.UserCookie;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.WhirledGameOccupantInfo;
import com.whirled.game.data.WhirledPlayerObject;

/**
 * Manages the backend of the game.
 */
public class BaseGameBackend
    implements MessageListener, SetListener, ElementUpdateListener, PropertySetListener, ChatDisplay
{
    /**
     * Magic number for <code>getMyId</code> to return if this is the server agent's backend.
     * @see #getMyId()
     */
    public static const SERVER_AGENT_ID :int = int.MIN_VALUE;

    /**
     * Magic number for sending a message to all players.
     */
    public static const TO_ALL :int = 0;

    public var log :Log = Log.getLog(this);

    public function BaseGameBackend (ctx :PresentsContext, gameObj :WhirledGameObject)
    {
        _ctx = ctx;
        _gameObj = gameObj;
        _gameStarted = _gameObj.isInPlay();
        _gameData = _gameObj.getUserProps();

        _gameObj.addListener(this);
        _ctx.getClient().getClientObject().addListener(_userListener);

        for each (var info :OccupantInfo in gameObj.occupantInfo.toArray()) {
            if (isInited(info)) {
                _idsToName[infoToId(info)] = info.username;
            }
        }
    }

    public function forceClassInclusion () :void
    {
        var c :Class;
        c = GameData;
        c = LevelData;
        c = ItemData;
        c = TrophyData;
    }

    public function setSharedEvents (disp :IEventDispatcher) :void
    {
        // old style listener. Deprecated 2008-02-15, but we'll probably always need it
        disp.addEventListener("ezgameQuery", handleUserCodeConnect);
        // newer listener
        disp.addEventListener("controlConnect", handleUserCodeConnect);
    }

    public function callUserCode (name :String, ... args) :*
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

    /**
     * Are we connected to the usercode on the front-end?
     */
    public function isConnected () :Boolean
    {
        return (_userFuncs != null);
    }

    public function getGameId () :int
    {
        return getConfig().getGameId();
    }

    public function shutdown () :void
    {
        _gameObj.removeListener(this);
        _ctx.getClient().getClientObject().removeListener(_userListener);
        callUserCode("connectionClosed_v1");
        _userFuncs = null; // disconnect
    }

    /**
     * Validate that we're not shutdown.
     */
    public function validateConnected () :void
    {
        if (_userFuncs == null) {
            throw new Error("Not connected.");
        }
    }

    /**
     * Called by the BaseGameController when the controller changes.
     */
    public function controlDidChange () :void
    {
        callUserCode("controlDidChange_v1");
    }

    /**
     * Called by the BaseGameController when the turn changes.
     */
    public function turnDidChange () :void
    {
        callUserCode("turnDidChange_v1");
    }

    /**
     * Called by the BaseGameController when the game starts or ends.
     */
    public function gameStateChanged (started :Boolean) :void
    {
        if (started && !readyToStart()) {
            // We're waiting to dispatch GAME_STARTED until the API is prepared to give out valid
            // player data for the current players. See doOccupantAdded.
            return;
        }

        // Since all the player data is ready, we "officially" go into play now, regardless of
        // whether the user code has connected.
        _gameStarted = started;

        if (_userFuncs == null) {
            // Normally this is not needed, because callUserCode will fail gracefully if we're
            // not connected. However, this method accesses _userFuncs directly, and it may not
            // yet be set up if the user is still downloading the game media.
            return;
        }

        if (started && _userFuncs["gameDidStart_v1"] != null) {
            callUserCode("gameDidStart_v1"); // backwards compatibility
        } else if (!started && _userFuncs["gameDidEnd_v1"] != null) {
            callUserCode("gameDidEnd_v1"); // backwards compatibility
        } else {
            callUserCode("gameStateChanged_v1", started); // new hotness
        }
    }

    /**
     * Called by the BaseGameController when a round starts or ends.
     */
    public function roundStateChanged (started :Boolean) :void
    {
        callUserCode("roundStateChanged_v1", started);
    }

    // from SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        var name :String = event.getName();
        switch (name) {
        case WhirledGameObject.USER_COOKIES:
            receivedUserCookie(event.getEntry() as UserCookie);
            break;

        case PlaceObject.OCCUPANT_INFO:
            var occInfo :OccupantInfo = (event.getEntry() as OccupantInfo)
            if (isInited(occInfo)) {
                occupantAdded(occInfo);
            }
            break;
        }
    }

    // from SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        var name :String = event.getName();
        switch (name) {
        case WhirledGameObject.USER_COOKIES:
            receivedUserCookie(event.getEntry() as UserCookie);
            break;

        case PlaceObject.OCCUPANT_INFO:
            var occInfo :WhirledGameOccupantInfo = (event.getEntry() as WhirledGameOccupantInfo);
            var oldInfo :WhirledGameOccupantInfo = (event.getOldEntry() as WhirledGameOccupantInfo);
            // Only report someone else if they transitioned from uninitialized to initialized
            // Note that our own occupantInfo will never pass this test, that is correct.
            if (isInited(occInfo)) {
                if (!isInited(oldInfo)) {
                    occupantAdded(occInfo);
                } else {
                    // update their name
                    _idsToName[infoToId(occInfo)] = occInfo.username;
                }
            }
            break;
        }
    }

    // from SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        var name :String = event.getName();
        switch (name) {
        case PlaceObject.OCCUPANT_INFO:
            var occInfo :OccupantInfo = (event.getOldEntry() as OccupantInfo)
            if (isInited(occInfo)) {
                occupantRemoved(occInfo);
            }
            break;
        }
    }

    // from ElementUpdateListener
    public function elementUpdated (event :ElementUpdatedEvent) :void
    {
        var name :String = event.getName();
        if (name == GameObject.PLAYERS) {
            var oldPlayer :Name = (event.getOldValue() as Name);
            var newPlayer :Name = (event.getValue() as Name);
            var occInfo :OccupantInfo;
            if (oldPlayer != null) {
                occInfo = _gameObj.getOccupantInfo(oldPlayer);
                if (isInited(occInfo)) {
                    occupantRoleChanged(occInfo, false);
                }
            }
            if (newPlayer != null) {
                occInfo = _gameObj.getOccupantInfo(newPlayer);
                if (isInited(occInfo)) {
                    occupantRoleChanged(occInfo, true);
                }
            }
        }
    }

    // from MessageListener
    public function messageReceived (event :MessageEvent) :void
    {
        var name :String = event.getName();
        if (WhirledGameObject.USER_MESSAGE == name) {
            dispatchUserMessage(event);

        } else if (WhirledGameObject.TICKER == name) {
            var targs :Array = event.getArgs();
            dispatchMessageReceived((targs[0] as String), (targs[1] as int), 0);
        }
    }

    // from PropertySetListener
    public function propertyWasSet (event :PropertySetEvent) :void
    {
        if (_userFuncs == null) {
            // Normally this is not needed, because callUserCode will fail gracefully if we're
            // not connected. However, this method accesses _userFuncs directly, and it may not
            // yet be set up if the user is still downloading the game media.
            return;
        }
        var key :Integer = event.getKey();
        if ("propertyWasSet_v1" in _userFuncs) {
            // dispatch the old way (Deprecated 2008-02-20, but we'll probably always need it)
            var index :int = (key == null) ? -1 : key.value;
            callUserCode("propertyWasSet_v1", event.getName(), event.getValue(),
                event.getOldValue(), index);

        } else {
            // dispatch the new way
            var keyObj :Object = (key == null) ? null : key.value;
            callUserCode("propertyWasSet_v2", event.getName(), event.getValue(),
                event.getOldValue(), keyObj);
        }
    }

    // from ChatDisplay
    public function clear () :void
    {
        // we do nothing
    }

    // from ChatDisplay
    public function displayMessage (msg :ChatMessage) :void
    {
        if (msg is UserMessage && msg.localtype == ChatCodes.PLACE_CHAT_TYPE) {
            var occInfo :OccupantInfo = _gameObj.getOccupantInfo(UserMessage(msg).speaker);
            // the game doesn't hear about the chat until the speaker is initialized
            if (isInited(occInfo)) {
                callUserCode("userChat_v1", infoToId(occInfo), msg.message);
            }
        }
    }

    /**
     * Lets the controller know that our user code is now ready to run. Does nothing by default,
     * so subclasses should override.
     */
    protected function notifyControllerUserCodeIsConnected (autoReady :Boolean) :void
    {
    }

    /**
     * Access the configuration of our game. This is an abstract method and must be provided
     * by subclasses.
     */
    protected function getConfig () :BaseGameConfig
    {
        throw new Error("Abstract method");
    }

    /**
     * Create a logging confirm listener for service requests.
     */
    protected function createLoggingConfirmListener (
        service :String, failure :Function = null,
        success :Function = null) :InvocationService_ConfirmListener
    {
        return new ConfirmAdapter(success, function (cause :String) :void {
            reportServiceFailure(service, cause);
            if (failure != null) {
                failure();
            }
        });
    }

    /**
     * Create a logging result listener for service requests.
     */
    protected function createLoggingResultListener (
        service :String, failure :Function = null,
        success :Function = null) :InvocationService_ResultListener
    {
        return new ResultAdapter(success, function (cause :String) :void {
            reportServiceFailure(service, cause);
            if (failure != null) {
                failure();
            }
        });
    }

    /**
     * Reports an invocation service failure. The default implementation reports the raw error
     * message via <code>reportGameError</code> but derived classes may want to actually translate
     * the message appropriately and then use reportGameError to report it.
     */
    protected function reportServiceFailure (service :String, cause :String) :void
    {
        reportGameError("Service failure [service=" + service + ", cause=" + cause + "].");
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

    /**
     * Helper for various occupantInfo-related bits. Returns true if the occupant info is not null
     * and is reportable to the usercode. Overriding this function will create bugs.
     */
    protected function isInited (occInfo :OccupantInfo) :Boolean
    {
        return (occInfo != null) &&
            ((occInfo as WhirledGameOccupantInfo).initialized ||
             (occInfo.bodyOid == _ctx.getClient().getClientOid()));
    }

    protected function readyToStart () :Boolean
    {
        return getPlayerInfos().every(Util.adapt(isInited));
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
     * Called by our user listener when we receive a message event on the user object.
     */
    protected function messageReceivedOnUserObject (event :MessageEvent) :void
    {
        var name :String = event.getName();
        if (WhirledPlayerObject.isFromGame(name, _gameObj.getOid())) {
            dispatchUserMessage(event);
        }
    }

    /**
     * Handle the arrival of a new UserCookie.
     */
    protected function receivedUserCookie (cookie :UserCookie) :void
    {
        if (_cookieCallbacks != null) {
            var arr :Array = (_cookieCallbacks[cookie.playerId] as Array);
            if (arr != null) {
                delete _cookieCallbacks[cookie.playerId];
                for each (var fn :Function in arr) {
                    // we want to decode every time, in case usercode mangles the value
                    var decodedValue :Object = ObjectMarshaller.decode(cookie.cookie);
                    try {
                        fn(decodedValue, cookie.playerId);
                    } catch (err :Error) {
                        reportGameError("Error in user-code: " + err, err);
                    }
                }
            }
        }
    }

    /**
     * Given the specified occupant name, return if they are a player.
     */
    protected function isPlayer (occupantName :Name) :Boolean
    {
        // in party games, everyone's a player
        return isParty() || (-1 != _gameObj.getPlayerIndex(occupantName));
    }

    protected function handleUserCodeConnect (evt :Event) :void
    {
        var props :Object = ("props" in evt) ? Object(evt).props : evt;

        // Old-style queries were deprecated 2008-02-18, but we'll probably always need them.
        // Old: eventName: "ezQuery", userProps: "userProps", ourProps: "ezProps"
        // New: eventName: "controlConnect", userProps: "userProps", ourProps: "hostProps"
        var hostPropName :String = (evt.type == "controlConnect") ? "hostProps" : "ezProps";

        var userProps :Object = props.userProps;
        setUserCodeProperties(userProps);

        var ourProps :Object = new Object();
        populateProperties(ourProps);
        props[hostPropName] = ourProps;

        // determine whether to automatically start the game in a backwards compatible way
        var autoReady :Boolean = ("autoReady_v1" in userProps) ? userProps["autoReady_v1"] : true;

        // ok, we're now hooked-up with the game code
        notifyControllerUserCodeIsConnected(autoReady);
    }

    protected function setUserCodeProperties (o :Object) :void
    {
        // here we would handle adapting old functions to a new version
        _userFuncs = o;
    }

    protected function populateProperties (o :Object) :void
    {
        // straight data
        o["gameData"] = _gameData;

        // convert our game config from a HashMap to a Dictionary
        var gameConfig :Object = {};
        var cfg :BaseGameConfig = getConfig();
        cfg.params.forEach(function (key :Object, value :Object) :void {
            gameConfig[key] = (value is Boxed) ? Boxed(value).unbox() : value;
        });
        o["gameConfig"] = gameConfig;
        o["gameInfo"] = createGameInfo();

        // GameControl
        o["commitTransaction"] = commitTransaction_v1;
        o["startTransaction"] = startTransaction_v1;

        // .net
        o["sendMessage_v2"] = sendMessage_v2;
        o["setProperty_v2"] = setProperty_v2;
        o["testAndSetProperty_v1"] = testAndSetProperty_v1;

        // .player
        o["getUserCookie_v2"] = getUserCookie_v2;
        o["getCookie_v1"] = getCookie_v1;
        o["setUserCookie_v1"] = setUserCookie_v1;
        o["setCookie_v1"] = setCookie_v1;
        o["isRegistered_v1"] = isRegistered_v1;
        o["holdsTrophy_v1"] = holdsTrophy_v1;
        o["awardTrophy_v1"] = awardTrophy_v1;
        o["awardPrize_v1"] = awardPrize_v1;
        o["getPlayerItemPacks_v1"] = getPlayerItemPacks_v1;
        o["getPlayerLevelPacks_v1"] = getPlayerLevelPacks_v1;
        o["requestConsumeItemPack_v1"] = requestConsumeItemPack_v1;

        // .game
        o["endGame_v2"] = endGame_v2;
        o["endGameWithScores_v1"] = endGameWithScores_v1;
        o["endGameWithWinners_v1"] = endGameWithWinners_v1;
        o["endRound_v1"] = endRound_v1;
        o["getControllerId_v1"] = getControllerId_v1;
        o["getLevelPacks_v2"] = getLevelPacks_v2;
        o["getItemPacks_v1"] = getItemPacks_v1;
        o["loadLevelPackData_v1"] = loadLevelPackData_v1;
        o["loadItemPackData_v1"] = loadItemPackData_v1;
        o["getOccupants_v1"] = getOccupants_v1;
        o["getOccupantName_v1"] = getOccupantName_v1;
        o["getRound_v1"] = getRound_v1;
        o["getTurnHolder_v1"] = getTurnHolder_v1;
        o["isInPlay_v1"] = isInPlay_v1;
        o["restartGameIn_v1"] = restartGameIn_v1;
        o["sendChat_v1"] = sendChat_v1;
        o["startNextTurn_v1"] = startNextTurn_v1;
        o["getMyId_v1"] = getMyId_v1;

        // .game.seating
        o["getPlayers_v1"] = getPlayers_v1;
        o["getPlayerPosition_v1"] = getPlayerPosition_v1;
        o["getMyPosition_v1"] = getMyPosition_v1;

        // .services
        o["checkDictionaryWord_v2"] = checkDictionaryWord_v2;
        o["getDictionaryLetterSet_v2"] = getDictionaryLetterSet_v2;
        o["getDictionaryWords_v1"] = getDictionaryWords_v1;
        o["setTicker_v1"] = setTicker_v1;

        // .services.bags
        o["getFromCollection_v2"] = getFromCollection_v2;
        o["mergeCollection_v1"] = mergeCollection_v1;
        o["populateCollection_v1"] = populateCollection_v1;

        // Old methods: backwards compatability
        o["awardFlow_v1"] = awardFlow_v1;
        o["awardFlow_v2"] = awardFlow_v2;
        o["checkDictionaryWord_v1"] = checkDictionaryWord_v1;
        o["endTurn_v2"] = startNextTurn_v1; // it's the same!
        o["getAvailableFlow_v1"] = getAvailableFlow_v1;
        o["getDictionaryLetterSet_v1"] = getDictionaryLetterSet_v1;
        o["setProperty_v1"] = setProperty_v1;
        o["getLevelPacks_v1"] = getLevelPacks_v1;
    }

    /**
     * Populate a small gameInfo property to communicate attributes to clients.
     */
    protected function createGameInfo () :Object
    {
        var o :Object = {};

        // for now, all we indicate is the game type
        o["type"] = getGameInfoType();

        return o;
    }

    /**
     * Get a String name for the game type.
     */
    protected function getGameInfoType () :String
    {
        var cfg :BaseGameConfig = getConfig();
        switch (cfg.getMatchType()) {
        case GameConfig.SEATED_GAME:
            return "seated";
        case GameConfig.SEATED_CONTINUOUS:
            return "seated_continuous";
        case GameConfig.PARTY:
            return "party";
        default:
            return "unknown";
        }
    }

    /**
     * Convenient method to see if we're in a party game.
     */
    protected function isParty () :Boolean
    {
        return (getConfig().getMatchType() == GameConfig.PARTY);
    }

    /**
     * Helper method for dispatching a message that may have come from more than one source
     * and/or message name.
     */
    protected function dispatchUserMessage (event :MessageEvent) :void
    {
        var args :Array = event.getArgs();
        var mname :String = (args[0] as String);
        var data :Object = ObjectMarshaller.decode(args[1]);
        var senderId :int = (args[2] as int);
        dispatchMessageReceived(mname, data, senderId);
    }

    /**
     * Disatpch a message to the right version of the messageReceived function.
     */
    protected function dispatchMessageReceived (
        mname :String, data :Object, senderId :int) :void
    {
        if (_userFuncs != null && ("messageReceived_v2" in _userFuncs)) {
            callUserCode("messageReceived_v2", mname, data, senderId);
        } else {
            callUserCode("messageReceived_v1", mname, data);
        }
    }

    //---- GameControl -----------------------------------------------------

    /**
     * Starts a transaction that will group all game state changes into a single message.
     */
    protected function startTransaction_v1 () :void
    {
        validateConnected();
        _ctx.getClient().getInvocationDirector().startTransaction();
    }

    /**
     * Commits a transaction started with <code>startTransaction_v1</code>.
     */
    protected function commitTransaction_v1 () :void
    {
        _ctx.getClient().getInvocationDirector().commitTransaction();
    }

    //---- .net ------------------------------------------------------------

    protected function sendMessage_v2 (messageName :String, value :Object, playerId :int) :void
    {
        validateConnected();
        validateName(messageName);
        validateValue(value);

        var encoded :Object = ObjectMarshaller.encode(value, false);
        var logger :InvocationService_ConfirmListener = createLoggingConfirmListener("sendMessage");
        if (playerId == TO_ALL) {
            _gameObj.messageService.sendMessage(messageName, encoded, logger);

        } else {
            // included here is handling EXCLUDE_AGENT, which happens on the server
            var players :TypedArray = TypedArray.create(int);
            players.push(playerId);
            _gameObj.messageService.sendPrivateMessage(messageName, encoded,
                players, logger);
        }
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
        validateConnected();
        validatePropertyChange(propName, value, isArray, int(key));

        var encoded :Object = PropertySpaceHelper.encodeProperty(value, (key == null));
        var ikey :Integer = (key == null) ? null : new Integer(int(key));
        _gameObj.propertyService.setProperty(propName, encoded, ikey, isArray, false, null,
            createLoggingConfirmListener("setProperty"));
        if (immediate) {
            // we re-decode so that it looks like it came off the net
            try {
                PropertySpaceHelper.applyPropertySet(
                    _gameObj, propName, PropertySpaceHelper.decodeProperty(encoded),
                    key, isArray);
            } catch (re :RangeError) {
                trace("Error setting property (immediate): " + re);
            }
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
        validateConnected();
        validatePropertyChange(propName, value, false, 0);

        var encodedValue :Object = PropertySpaceHelper.encodeProperty(value, true);
        var encodedTestValue :Object = PropertySpaceHelper.encodeProperty(testValue, true);
        _gameObj.propertyService.setProperty(
            propName, encodedValue, null, false, true, encodedTestValue,
            createLoggingConfirmListener("testAndSetProperty"));
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
        validateConnected();
        occupantId = transformId(occupantId);

        // see if that cookie is already published
        if (_gameObj.userCookies != null) {
            var uc :UserCookie = (_gameObj.userCookies.get(occupantId) as UserCookie);
            if (uc != null) {
                callback(ObjectMarshaller.decode(uc.cookie), occupantId);
                return;
            }
        }

        if (_cookieCallbacks == null) {
            _cookieCallbacks = new Dictionary();
        }
        var arr :Array = (_cookieCallbacks[occupantId] as Array);
        if (arr == null) {
            arr = [];
            _cookieCallbacks[occupantId] = arr;
        }
        arr.push(callback);

        // request it to be made so by the server
        _gameObj.whirledGameService.getCookie(
            occupantId, createLoggingConfirmListener("getCookie"));
    }

    protected function setUserCookie_v1 (
        cookie :Object, playerId :int = CURRENT_USER) :Boolean
    {
        return setCookie_v1(cookie, playerId);
    }

    protected function setCookie_v1 (
        cookie :Object, occupantId :int = CURRENT_USER) :Boolean
    {
        validateConnected();
        occupantId = transformId(occupantId);
        validateValue(cookie);
        var ba :ByteArray = (ObjectMarshaller.encode(cookie, false) as ByteArray);
        if (ba.length > MAX_USER_COOKIE) {
            // not saved!
            return false;
        }

        _gameObj.whirledGameService.setCookie(
            ba, occupantId, createLoggingConfirmListener("setCookie"));
        return true;
    }

    protected function isRegistered_v1 (playerId :int = CURRENT_USER) :Boolean
    {
        return false; // derived classes do The Right Thing (tm)
    }

    protected function holdsTrophy_v1 (
        ident :String, playerId :int = CURRENT_USER) :Boolean
    {
        return countPlayerData(GameData.TROPHY_DATA, ident, playerId) > 0;
    }

    protected function awardTrophy_v1 (
        ident :String, playerId :int = CURRENT_USER) :Boolean
    {
        if (holdsTrophy_v1(ident, playerId)) {
            return false;
        }

        _gameObj.prizeService.awardTrophy(
            ident, playerId, createLoggingConfirmListener("awardTrophy"));

        return true;
    }

    protected function awardPrize_v1 (
        ident :String, playerId :int = CURRENT_USER) :void
    {
        if (countPlayerData(GameData.PRIZE_MARKER, ident, playerId) == 0) {
            _gameObj.prizeService.awardPrize(
                ident, playerId, createLoggingConfirmListener("awardPrize"));
        }
    }

    protected function getPlayerItemPacks_v1 (
        playerId :int = CURRENT_USER) :Array
    {
        return getItemPacks_v1(function (data :GameData) :int {
            return countPlayerData(data.getType(), data.ident, playerId);
        });
    }

    protected function getPlayerLevelPacks_v1 (playerId :int = CURRENT_USER) :Array
    {
        return getLevelPacks_v2(function (data :GameData) :Boolean {
            return countPlayerData(data.getType(), data.ident, playerId) > 0;
        });
    }

    protected function requestConsumeItemPack_v1 (ident :String, msg :String) :Boolean
    {
        return false; // default implementation always rejects consumption
    }

    //---- .game -----------------------------------------------------------

    protected function sendChat_v1 (msg :String) :void
    {
        validateConnected();
        validateChat(msg);
        // Post a message to the game object, the controller will listen and call localChat().
        _gameObj.postMessage(WhirledGameObject.GAME_CHAT, [ msg ]);
    }

    protected function getLevelPacks_v2 (filter :Function = null) :Array
    {
        var packs :Array = [];
        for each (var data :GameData in _gameObj.gameData) {
            if (data.getType() != GameData.LEVEL_DATA || (filter != null && !filter(data))) {
                continue;
            }
            packs.unshift({ ident: data.ident,
                            name: data.name,
                            mediaURL: data.mediaURL,
                            premium: (data as LevelData).premium });
        }
        return packs;
    }

    protected function getItemPacks_v1 (filter :Function = null) :Array
    {
        var packs :Array = [];
        for each (var data :GameData in _gameObj.gameData) {
            if (data.getType() != GameData.ITEM_DATA) {
                continue;
            }
            var count :int = (filter == null) ? 1 : filter(data);
            if (count == 0) {
                continue;
            }
            packs.unshift({ ident: data.ident,
                            name: data.name,
                            mediaURL: data.mediaURL,
                            count: count });
        }
        return packs;
    }

    protected function loadLevelPackData_v1 (
        ident :String, onLoaded :Function, onFailure :Function) :void
    {
        loadPackData(ident, GameData.LEVEL_DATA, onLoaded, onFailure);
    }

    protected function loadItemPackData_v1 (
        ident :String, onLoaded :Function, onFailure :Function) :void
    {
        loadPackData(ident, GameData.ITEM_DATA, onLoaded, onFailure);
    }

    protected function loadPackData (
        ident :String, type :int, onLoaded :Function, onFailure :Function) :void
    {
        var data :GameData = getGameData(ident, type);
        if (data == null) {
            if (onFailure != null) {
                onFailure(new Error("Unknown data pack: " + ident));
            }
            return;
        }

        if (_loadedPacks[data.mediaURL]) {
            // TODO: too draconian? should we cache these on the server?
            if (onFailure != null) {
                onFailure(new Error("Data pack has already been loaded this session: " + ident));
            }
            return;
        }

        // we'll call it loaded even when it's just loading
        _loadedPacks[data.mediaURL] = true;

        var loader :URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener(IOErrorEvent.IO_ERROR, function (evt :IOErrorEvent) :void {
            if (onFailure != null) {
                onFailure(new IOError("I/O Error: " + evt.text));
            }
            // give the game a chance to try again
            delete _loadedPacks[data.mediaURL];
        });
        loader.addEventListener(Event.COMPLETE, function (evt :Event) :void {
            // TODO: we should be able to ensure position = 0 at a lower level
            var ba :ByteArray = ByteArray(loader.data);
            ba.position = 0;
            onLoaded(ba);
        });
        loader.load(new URLRequest(data.mediaURL));
    }

    protected function getGameData (ident :String, type :int) :GameData
    {
        for each (var data :GameData in _gameObj.gameData) {
            if (data.getType() == type && data.ident == ident) {
                return data;
            }
        }
        return null;
    }

    protected function getOccupants_v1 () :Array
    {
        validateConnected();
        var occs :Array = [];
        for each (var occInfo :OccupantInfo in _gameObj.occupantInfo.toArray()) {
            if (isInited(occInfo)) {
                occs.push(infoToId(occInfo));
            }
        }
        return occs;
    }

    protected function getOccupantName_v1 (playerId :int) :String
    {
        validateConnected();
        var name :Name = _idsToName[playerId]; // contains only mapping for init'd players
        return (name == null) ? null : name.toString();
    }

    protected function getControllerId_v1 () :int
    {
        validateConnected();
        return _gameObj.controllerId;
    }

    protected function getTurnHolder_v1 () :int
    {
        validateConnected();
        var occInfo :OccupantInfo = _gameObj.getOccupantInfo(_gameObj.turnHolder);
        return isInited(occInfo) ? infoToId(occInfo) : 0;
    }

    protected function getRound_v1 () :int
    {
        validateConnected();
        return _gameObj.roundId;
    }

    protected function isInPlay_v1 () :Boolean
    {
        validateConnected();
        return _gameStarted;
    }

    protected function startNextTurn_v1 (nextPlayerId :int) :void
    {
        validateConnected();
        _gameObj.whirledGameService.endTurn(
            nextPlayerId, createLoggingConfirmListener("endTurn"));
    }

    protected function endRound_v1 (nextRoundDelay :int) :void
    {
        validateConnected();
        _gameObj.whirledGameService.endRound(
            nextRoundDelay, createLoggingConfirmListener("endRound"));
    }

    protected function endGame_v2 (... winnerIds) :void
    {
        validateConnected();

        // if this is a table game, all the non-winners are losers, if it's not a table game then
        // no one is a loser because we're not going to declare that all watchers automatically be
        // considered as players and thus contribute to the winners' booty
        var loserIds :Array = [];
        for each (var info :OccupantInfo in getPlayerInfos().filter(Util.adapt(isInited))) {
            loserIds.push(infoToId(info));
        }
        endGameWithWinners_v1(winnerIds, loserIds, 0) // WhirledGameControl.CASCADING_PAYOUT
    }

    protected function endGameWithWinners_v1 (
        winnerIds :Array, loserIds :Array, payoutType :int) :void
    {
        validateConnected();

        // pass the buck straight on through, the server will validate everything
        _gameObj.whirledGameService.endGameWithWinners(
            TypedArray.create(int, winnerIds), TypedArray.create(int, loserIds),
            payoutType, createLoggingConfirmListener("endGameWithWinners"));
    }

    // gameMode was added on Oct-23-2008, most games will continue to use the default mode, but new
    // games may pass a non-zero value to make use of per-mode score distributions
    protected function endGameWithScores_v1 (
        playerIds :Array, scores :Array /* of int */, payoutType :int, gameMode :int = 0) :void
    {
        validateConnected();

        // pass the buck straight on through, the server will validate everything
        _gameObj.whirledGameService.endGameWithScores(
            TypedArray.create(int, playerIds), TypedArray.create(int, scores),
            payoutType, gameMode, createLoggingConfirmListener("endGameWithScores"));
    }

    protected function restartGameIn_v1 (seconds :int) :void
    {
        validateConnected();
        if (!isParty()) {
            // I'd like to throw an error, but some old games incorrectly call this
            // and we don't want to break them, so just log it here, but we throw an Error
            // in newer versions of GameSubControl.
            reportGameError("restartGameIn() is only applicable to party games.");
            return;
        }
        _gameObj.whirledGameService.restartGameIn(
            seconds, createLoggingConfirmListener("restartGameIn"));
    }

    protected function getMyId_v1 () :int
    {
        throw new Error("Abstract method");
    }

    //---- .game.seating ---------------------------------------------------

    protected function getPlayerPosition_v1 (playerId :int) :int
    {
        validateConnected();
        var name :Name = _idsToName[playerId]; // contains only inited occs
        return (name == null) ? -1 : _gameObj.getPlayerIndex(name);
    }

    protected function getPlayers_v1 () :Array
    {
        validateConnected();
        return getPlayerIds();
    }

    protected function getMyPosition_v1 () :int
    {
        // Note: this is overridden in the whirled backend
        return -1;
    }

    //---- .services -------------------------------------------------------

    protected function setTicker_v1 (tickerName :String, msOfDelay :int) :void
    {
        validateConnected();
        validateName(tickerName);
        _gameObj.whirledGameService.setTicker(
            tickerName, msOfDelay, createLoggingConfirmListener("setTicker"));
    }

    protected function getDictionaryLetterSet_v2 (
        locale :String, dictionary :String, count :int, callback :Function) :void
    {
        validateConnected();
        var listener :InvocationService_ResultListener;
        var failure :Function = function (cause :String) :void {
            // ignore the cause, return an empty array
            callback([]);
        };
        var success :Function = function (result :String) :void {
            // splice the resulting string, and return as array
            var r :Array = result.split(",");
            callback(r);
        };
        listener = createLoggingResultListener("getDictionaryLetterSet", failure, success);

        // just relay the data over to the server
        _gameObj.whirledGameService.getDictionaryLetterSet(locale, dictionary, count, listener);
    }

    protected function getDictionaryWords_v1 (
        locale :String, dictionary :String, count :int, callback :Function) :void
    {
        validateConnected();
        var listener :InvocationService_ResultListener;
        var failure :Function = function (cause :String) :void {
            // ignore the cause, return an empty array
            callback([]);
        };
        var success :Function = function (result :String) :void {
            // splice the resulting string, and return as array
            var r :Array = result.split(",");
            callback(r);
        };
        listener = createLoggingResultListener("getDictionaryWords", failure, success);

        // just relay the data over to the server
        _gameObj.whirledGameService.getDictionaryWords(locale, dictionary, count, listener);
    }

    protected function checkDictionaryWord_v2 (
        locale :String, dictionary :String, word :String, callback :Function) :void
    {
        validateConnected();
        var listener :InvocationService_ResultListener;
        var failure :Function = function (cause :String) :void {
            // ignore the cause, return failure
            callback(word, false);
        };
        var success :Function = function (result :Object) :void {
            // server returns a boolean, so convert it and send it over
            var r :Boolean = result as Boolean;
            callback(word, r);
        };
        listener = createLoggingResultListener("checkDictionaryWord", failure, success);

        // just relay the data over to the server
        _gameObj.whirledGameService.checkDictionaryWord(locale, dictionary, word, listener);
    }

    //---- .services.bags --------------------------------------------------

    protected function mergeCollection_v1 (srcColl :String, intoColl :String) :void
    {
        validateConnected();
        validateName(srcColl);
        validateName(intoColl);
        _gameObj.whirledGameService.mergeCollection(srcColl, intoColl,
            createLoggingConfirmListener("mergeCollection"));
    }

    /**
     * Helper method for setCollection and addToCollection.
     */
    protected function populateCollection_v1 (
        collName :String, values :Array, clearExisting :Boolean) :void
    {
        validateConnected();
        validateName(collName);
        if (values == null) {
            throw new ArgumentError("Collection values may not be null.");
        }
        validateValue(values);

        var encodedValues :TypedArray = (ObjectMarshaller.encode(values, true) as TypedArray);
        _gameObj.whirledGameService.addToCollection(collName, encodedValues, clearExisting,
            createLoggingConfirmListener("populateCollection"));
    }

    /**
     * Helper method for pickFromCollection and dealFromCollection.
     */
    protected function getFromCollection_v2 (
        collName :String, count :int, msgOrPropName :String, playerId :int,
        consume :Boolean, callback :Function) :void
    {
        validateConnected();
        validateName(collName);
        validateName(msgOrPropName);
        if (count < 1) {
            throw new ArgumentError("Must retrieve at least one element!");
        }

        var listener :InvocationService_ConfirmListener;
        if (callback != null) {
            listener = createLoggingConfirmListener("getFromCollection",
                function () :void {
                    callback(0);
                },
                function () :void {
                    callback(count);
                }
            );

        } else {
            listener = createLoggingConfirmListener("getFromCollection");
        }

        _gameObj.whirledGameService.getFromCollection(
            collName, consume, count, msgOrPropName, playerId, listener);
    }

    //---- backwards compatability -----------------------------------------

    protected function getDictionaryLetterSet_v1 (
        locale :String, count :int, callback :Function) :void
    {
        getDictionaryLetterSet_v2(locale, null, count, callback);
    }

    protected function checkDictionaryWord_v1 (
        locale :String, word :String, callback :Function) :void
    {
        checkDictionaryWord_v2(locale, null, word, callback);
    }

    /** A backwards compatible method. */
    protected function getAvailableFlow_v1 () :int
    {
        return 0;
    }

    /** A backwards compatible method. */
    protected function awardFlow_v1 (amount :int) :void
    {
        // NOOP!
    }

    /** A backwards compatible method. */
    protected function awardFlow_v2 (perf :int) :int
    {
        return 0;
    }

    /** A backwards compatible method. */
    protected function getLevelPacks_v1 (ignored :* = null) :Array
    {
        return getLevelPacks_v2()
    }

    /**
     * A backwards compatible method.
     *
     * Note: immediate defaults to true, even though immediate=false is the general case. We are
     * providing some backwards compatibility to old versions of setProperty_v1() that assumed
     * immediate and did not pass a 4th value.  All callers should now specify that value
     * explicitly. (And of course, setProperty_v2 takes control of this situation.)
     */
    protected function setProperty_v1 (
        propName :String, value :Object, index :int, immediate :Boolean = true) :void
    {
        var key :Object = (index < 0) ? null : index;
        var isArray :Boolean = (key != null);
        setProperty_v2(propName, value, key, isArray, immediate);
    }

    // --------------------------

    /**
     * Returns the number of copies of the specified data that is owned by the player.
     */
    protected function countPlayerData (type :int, ident :String, playerId :int) :int
    {
        return 0; // this information is provided by the containing system
    }

    /**
     * Called when the occupant set gets a new initialized entry (or an exisiting entry gets
     * initialized)
     */
    protected function occupantAdded (occInfo :OccupantInfo) :void
    {
        doOccupantAdded(occInfo);
    }

    /**
     * Dispatches the addition of an occupant to the user code, including starting the game if the
     * addition of the occupant means that the game is ready to start.
     */
    protected function doOccupantAdded (occInfo :OccupantInfo) :void
    {
        var id :int = infoToId(occInfo);
        _idsToName[id] = occInfo.username;
        callUserCode("occupantChanged_v1", id, isPlayer(occInfo.username), true);

        if (!_gameStarted && _gameObj.isInPlay()) {
            gameStateChanged(true);
        }
    }

    /**
     * Called when the occupant set loses an entry.
     */
    protected function occupantRemoved (occInfo :OccupantInfo) :void
    {
        doOccupantRemoved(occInfo);
    }

    /**
     * Dispatches the removal of an occupant to the user code.
     */
    protected function doOccupantRemoved (occInfo :OccupantInfo) :void
    {
        var id :int = infoToId(occInfo);
        callUserCode("occupantChanged_v1", id, isPlayer(occInfo.username), false);
        delete _idsToName[id];
    }

    /**
     * Called when an occupant's player status changes.
     */
    protected function occupantRoleChanged (occInfo :OccupantInfo, isPlayerNow :Boolean) :void
    {
        doOccupantRoleChanged(occInfo, isPlayerNow);
    }

    /**
     * Dispatches the change in player status to the user code.
     */
    protected function doOccupantRoleChanged (occInfo :OccupantInfo, isPlayerNow :Boolean) :void
    {
        var id :int = infoToId(occInfo);
        // let the user code know about this by sending a "left" followed by an "entered" message
        callUserCode("occupantChanged_v1", id, !isPlayerNow, false);
        callUserCode("occupantChanged_v1", id, isPlayerNow, true);
    }

    /**
     * Returns an array of OccupantInfo for all players in the game. Players that have been taken
     * over by the server are omitted from this array. Players that have not been taken over by the
     * server but are not in the game room have null in their slot.
     */
    protected function getPlayerInfos () :Array
    {
        var infos :Array = [];
        for each (var name :Name in _gameObj.players) {
            if (name == null) {
                continue; // this player is an AI, skip them
            }
            infos.push(_gameObj.getOccupantInfo(name));
        }
        return infos;
    }

    /**
     * Returns an array of ids for all players in the game. Players that have been taken over by
     * the server or that are not yet initialized have a 0 filled in for their slot.
     */
    protected function getPlayerIds () :Array
    {
        var playerIds :Array = [];
        for each (var name :Name in _gameObj.players) {
            var occInfo :OccupantInfo = _gameObj.getOccupantInfo(name);
            playerIds.push(isInited(occInfo) ? infoToId(occInfo) : 0);
        }
        return playerIds;
    }

    /**
     * Turn the CURRENT_USER id into a real id, rejecting the agent.
     */
    protected function transformId (id :int) :int
    {
        if (id == CURRENT_USER) {
            id = getMyId_v1();
            if (id == SERVER_AGENT_ID) {
                throw new Error("Server agent must provide a player id here");
            }
        }
        return id;
    }

    /**
     * Get the persistent id for this player's name. This is required for whirled games.
     */
    protected function nameToId (name :Name) :int
    {
        return UserIdentifier.getUserId(name);
    }

    /**
     * Get the persistent id for this occupantInfo. This is required for whirled games.
     */
    protected function infoToId (occInfo :OccupantInfo) :int
    {
        return nameToId(occInfo.username);
    }

    protected var _ctx :PresentsContext;
    protected var _gameObj :WhirledGameObject;
    protected var _userFuncs :Object;
    protected var _gameData :Object;

    protected var _userListener :MessageAdapter = new MessageAdapter(messageReceivedOnUserObject);

    /** Maps ids to name for inited occupants. */
    protected var _idsToName :Dictionary = new Dictionary();

    /** playerIndex -> callback functions waiting for the cookie. */
    protected var _cookieCallbacks :Dictionary;

    /** URL -> boolean for data packs that have been loaded */
    protected var _loadedPacks :Dictionary = new Dictionary();

    /** A flag for whether we've been told we've been started, which is not precisely the same
     * as _gameObj.isInPlay() */
    protected var _gameStarted :Boolean = false;

    protected static const MAX_USER_COOKIE :int = 4096;
    protected static const CURRENT_USER :int = 0;
}
}

