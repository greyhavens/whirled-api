//
// $Id$

package com.whirled.game.server;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.inject.Inject;

import com.samskivert.util.ArrayIntSet;
import com.samskivert.util.Interval;
import com.samskivert.util.IntIntMap;
import com.samskivert.util.IntListUtil;
import com.samskivert.util.RandomUtil;
import com.samskivert.util.ResultListener;
import com.samskivert.util.StringUtil;

import com.threerings.util.Name;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.dobj.AccessController;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.ObjectDeathListener;
import com.threerings.presents.dobj.ObjectDestroyedEvent;
import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.server.CrowdObjectAccess;

import com.threerings.bureau.server.BureauRegistry;

import com.threerings.parlor.game.data.GameAI;
import com.threerings.parlor.game.data.GameConfig;
import com.threerings.parlor.game.server.GameManager;
import com.threerings.parlor.turn.server.TurnGameManager;

import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.WhirledGameOccupantInfo;
import com.whirled.game.data.UserCookie;
import com.whirled.game.data.WhirledGameConfig;
import com.whirled.game.data.ThaneGameConfig;
import com.whirled.game.data.GameDefinition;
import com.whirled.game.server.ContentDispatcher;

import com.whirled.bureau.data.BureauTypes;
import com.whirled.bureau.data.GameAgentObject;

import static com.whirled.game.Log.log;

/**
 * A manager for whirled games.
 */
public abstract class WhirledGameManager extends GameManager
    implements WhirledGameProvider, TurnGameManager, ContentProvider, PrizeProvider
{
    /** The default class name to use for the game agent. */
    public static final String DEFAULT_SERVER_CLASS = "Server";

    /** The magic player id constant for sending a collection change to all players. */
    public static final int TO_ALL = 0;

    /** The magic player id constant for the server agent used when sending private messages. */
    public static final int SERVER_AGENT = Integer.MIN_VALUE;

    public WhirledGameManager ()
    {
    }

    /**
     * Configures the ids of the winners of this game. If a game manager delegate wishes to handle
     * winner assignment, it should call this method and then call {@link #endGame}.
     */
    public void setWinners (Name[] winners)
    {
        _winners = winners;
    }

    @Override // from PlaceManager
    public void bodyWillEnter (BodyObject body)
    {
        super.bodyWillEnter(body);

        int id = getPlayerPersistentId(body);
        _idToOid.put(id, body.getOid());

        // if we have no controller, then our new friend gets control
        if (_gameObj.controllerId == 0) {
            _gameObj.setControllerId(id);
        }
    }

    @Override // from PlaceManager
    public void bodyWillLeave (BodyObject body)
    {
        super.bodyWillLeave(body);

        int id = getPlayerPersistentId(body);
        _idToOid.remove(id);
        // if this player was the controller, reassign control
        if (id == _gameObj.controllerId) {
            _gameObj.setControllerId(getControllerId());
        }

        // nix any of this player's cookies
        if (_gameObj.userCookies != null && _gameObj.userCookies.containsKey(id)) {
            _gameObj.removeFromUserCookies(id);
        }
    }

    @Override // from GameManager
    public void occupantInRoom (final BodyObject caller)
    {
        resolveContentOwnership(caller, new ResultListener<Void>() {
            public void requestCompleted (Void result) {
                setAsInitialized(caller);
            }
            public void requestFailed (Exception cause) {
                log.warning("Ownership content resolution failed!", "game", where(),
                            "caller", caller.username, cause);
            }
        });

        super.occupantInRoom(caller);
    }

/*
    @Override
    public void playerReady (BodyObject caller)
    {
        // if we're rematching...
        if (!_gameObj.isInPlay() && (_gameObj.roundId != 0) && _gameObj.players.length > 1) {
            // report to the other players that this player requested a rematch
            int pidx = _gameObj.getPlayerIndex(caller.getVisibleName());
            if (pidx != -1 && _playerOids[pidx] == 0) {
                systemMessage(WHIRLEDGAME_MESSAGE_BUNDLE,
                    MessageBundle.tcompose("m.rematch_requested", caller.getVisibleName()));
            }
        }

        super.playerReady(caller);
    }
*/

    @Override
    protected AccessController getAccessController ()
    {
        return _injector.getInstance(CrowdObjectAccess.BureauAccessController.class);
    }

    /**
     * Confirms that the caller can end the game (or restart it). Requires that they are a player
     * and that the game is not in play.
     */
    public void validateCanEndGame (ClientObject caller)
        throws InvocationException
    {
        if (!_gameObj.isInPlay()) {
            throw new InvocationException("e.already_ended");
        }
        validateUser(caller);
    }

    // from TurnGameManager
    public void turnWillStart ()
    {
    }

    // from TurnGameManager
    public void turnDidStart ()
    {
    }

    // from TurnGameManager
    public void turnDidEnd ()
    {
    }

    // from WhirledGameProvider
    public void endTurn (ClientObject caller, int nextPlayerId,
                         InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

//        // make sure this player is the turn holder
//        Name holder = _gameObj.turnHolder;
//        if (holder != null && !holder.equals(((BodyObject) caller).getVisibleName())) {
//            throw new InvocationException(InvocationCodes.ACCESS_DENIED);
//        }

//        Name nextTurnHolder = null;
//        if (nextPlayerId != 0) {
//            BodyObject target = getPlayerByOid(nextPlayerId);
//            if (target != null) {
//                nextTurnHolder = target.getVisibleName();
//            }
//        }

        if (nextPlayerId == 0 && _gameObj.getActivePlayerCount() < 2) {
            throw new InvocationException("e.not_enough_players");
        }

        _turnDelegate.endTurn(nextPlayerId);
    }

    // from WhirledGameProvider
    public void endRound (ClientObject caller, int nextRoundDelay,
                          InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

        // let the game know that it is doing something stupid
        if (_gameObj.roundId < 0) {
            throw new InvocationException("m.round_already_ended");
        }

        // while we are between rounds, our round id is the negation of the round that just ended
        _gameObj.setRoundId(-_gameObj.roundId);

        // queue up the start of the next round if requested
        if (nextRoundDelay > 0) {
            new Interval(_omgr) {
                public void expired () {
                    if (_gameObj.isInPlay()) {
                        _gameObj.setRoundId(-_gameObj.roundId + 1);
                    }
                }
            }.schedule(nextRoundDelay * 1000L);
        }
    }

    // from WhirledGameProvider
    public void restartGameIn (ClientObject caller, int seconds,
                               InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

        // queue up the start of the next game
        if (seconds > 0) {
            new Interval(_omgr) {
                public void expired () {
                    if (_gameObj.isActive() && !_gameObj.isInPlay()) {
                        startGame();
                    }
                }
            }.schedule(seconds * 1000L);

        } else {
            // start immediately
            if (_gameObj.isActive() && !_gameObj.isInPlay()) {
                startGame();
            }
        }
    }

    // from WhirledGameProvider
    public void getDictionaryLetterSet (ClientObject caller, String locale, String dictionary,
                                        int count, InvocationService.ResultListener listener)
        throws InvocationException
    {
        // No negative counts please
        count = Math.max(0, count);

        _dictMgr.getLetterSet(locale, dictionary, count, listener);
    }

    // from WhirledGameProvider
    public void getDictionaryWords (
        ClientObject caller, String locale, String dictionary, int count,
        InvocationService.ResultListener listener)
        throws InvocationException
    {
        // Clamp the words count to 0..100
        count = Math.max(0, Math.min(count, 100));

        _dictMgr.getWords(locale, dictionary, count, listener);
    }

    // from WhirledGameProvider
    public void checkDictionaryWord (ClientObject caller, String locale, String dictionary,
                                     String word, InvocationService.ResultListener listener)
        throws InvocationException
    {
        _dictMgr.checkWord(locale, dictionary, word, listener);
    }

    // from WhirledGameProvider
    public void addToCollection (ClientObject caller, String collName, byte[][] data,
                                 boolean clearExisting,
                                 InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);
        if (_collections == null) {
            _collections = Maps.newHashMap();
        }

        // figure out if we're adding to an existing collection or creating a new one
        List<byte[]> list = null;
        if (!clearExisting) {
            list = _collections.get(collName);
        }
        if (list == null) {
            _collections.put(collName, list = Lists.newArrayList());
        }

        Collections.addAll(list, data);
    }

    // from WhirledGameProvider
    public void getFromCollection (ClientObject caller, String collName, boolean consume, int count,
                                   String msgOrPropName, int playerId,
                                   InvocationService.ConfirmListener listener)
        throws InvocationException
    {
        validateUser(caller);

        int srcSize = 0;
        if (_collections != null) {
            List<byte[]> src = _collections.get(collName);
            srcSize = (src == null) ? 0 : src.size();
            if (srcSize >= count) {
                byte[][] result = new byte[count][];
                for (int ii=0; ii < count; ii++) {
                    int pick = RandomUtil.getInt(srcSize);
                    if (consume) {
                        result[ii] = src.remove(pick);
                        srcSize--;

                    } else {
                        result[ii] = src.get(pick);
                    }
                }

                if (playerId == TO_ALL) {
                    _propertySpaceHandler.setProperty(
                        null, msgOrPropName, result, null, false, false, null, null);
                } else {
                    _messageHandler.sendPrivateMessage(caller, msgOrPropName, result,
                        new int[] {playerId}, null);
                }
                listener.requestProcessed(); // SUCCESS!

            } else {
                throw new InvocationException("Not enough elements");
            }

        } else {
            throw new InvocationException("Collection not found");
        }
    }

    // from WhirledGameProvider
    public void mergeCollection (ClientObject caller, String srcColl, String intoColl,
                                 InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

        // non-existent collections are treated as empty, so if the source doesn't exist, we
        // silently accept it
        if (_collections != null) {
            List<byte[]> src = _collections.remove(srcColl);
            if (src != null) {
                List<byte[]> dest = _collections.get(intoColl);
                if (dest == null) {
                    _collections.put(intoColl, src);
                } else {
                    dest.addAll(src);
                }
            }
        }
    }

    // from WhirledGameProvider
    public void setTicker (ClientObject caller, String tickerName, int msOfDelay,
                           InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);

        Ticker t;
        if (msOfDelay >= MIN_TICKER_DELAY) {
            if (_tickers != null) {
                t = _tickers.get(tickerName);
            } else {
                _tickers = Maps.newHashMap();
                t = null;
            }

            if (t == null) {
                if (_tickers.size() >= MAX_TICKERS) {
                    throw new InvocationException("e.too_many_tickers");
                }
                t = new Ticker(tickerName, _gameObj);
                _tickers.put(tickerName, t);
            }
            t.start(msOfDelay);

        } else if (msOfDelay <= 0) {
            if (_tickers != null) {
                t = _tickers.remove(tickerName);
                if (t != null) {
                    t.stop();
                }
            }

        } else {
            throw new InvocationException("e.delay_too_short");
        }
    }

    // from WhirledGameProvider
    public void getCookie (ClientObject caller, final int playerId,
                           InvocationService.InvocationListener listener)
        throws InvocationException
    {
        if (_gameObj.userCookies != null && _gameObj.userCookies.containsKey(playerId)) {
            // already loaded: we do nothing
            return;
        }

        // we only start looking up the cookie if nobody else already is
        if (_cookieLookups.contains(playerId)) {
            return;
        }

        BodyObject body = getOccupantById(playerId);
        if (body == null) {
            log.debug("getCookie() called with invalid occupant", "game", where(),
                      "occupantId", playerId);
            throw new InvocationException(INTERNAL_ERROR);
        }

        // indicate that we're looking up a cookie
        _cookieLookups.add(playerId);

        final int bodyOid = body.getOid();
        _cookMgr.getCookie(getGameId(), playerId, new ResultListener<byte[]>() {
            public void requestCompleted (byte[] result) {
                // note that we're done with this lookup
                _cookieLookups.remove(playerId);
                // result may be null: that's ok, it means we've looked up the user's nonexistent
                // cookie; also only set the cookie if the player is still in the room
                if (_gameObj.occupants.contains(bodyOid) && _gameObj.isActive()) {
                    _gameObj.addToUserCookies(new UserCookie(playerId, result));
                }
            }

            public void requestFailed (Exception cause) {
                log.warning("Unable to retrieve cookie", "game", where(), cause);
                requestCompleted(null);
            }
        });
    }

    // from WhirledGameProvider
    public void setCookie (ClientObject caller, byte[] value, int playerId,
                           InvocationService.InvocationListener listener)
        throws InvocationException
    {
        validateUser(caller);
        // make sure the playerId is valid
        playerId = validatePlayerId(caller, playerId);

        // persist this new cookie
        _cookMgr.setCookie(getGameId(), playerId, value);

        // and update the distributed object
        UserCookie cookie = new UserCookie(playerId, value);
        if (_gameObj.userCookies.containsKey(cookie.getKey())) {
            _gameObj.updateUserCookies(cookie);
        } else {
            _gameObj.addToUserCookies(cookie);
        }
    }

    // from WhirledGameProvider
    public void makePlayerAI (ClientObject caller, int playerId,
                              InvocationService.InvocationListener listener)
        throws InvocationException
    {
        requireAgent(caller);

        // find this player's position and put an AI therein
        for (int pidx = 0; pidx < getPlayerSlots(); pidx++) {
            Name pname = _gameObj.players[pidx];
            if (pname != null && getPlayerPersistentId(pname) == playerId) {
                setAI(pidx, new GameAI(0, 0));
                // clear out the player's name from the players array so that Thane and the client
                // code know this is no longer a real player
                _gameObj.setPlayersAt(null, pidx);
                // possibly do players all here processing
                if (allPlayersReady()) {
                    playersAllHere();
                }
                break;
            }
        }
    }

    /**
     * Called privately by the ThaneGameController when an agent's code is all set to go
     * and the game can startup.
     */
    public void agentReady (ClientObject caller)
    {
        log.info("Agent ready", "game", where(), "caller", caller);
        _gameAgentReady = true;
        _gameObj.setAgentState(WhirledGameObject.AGENT_READY);

        // possibly do players all here processing
        if (allPlayersReady()) {
            playersAllHere();
        }
    }

    /**
     * Called privately by the ThaneGameController when an agent's code could not be started.
     */
    public void agentFailed (ClientObject caller)
    {
        log.info("Agent failed", "game", where(), "caller", caller);

        _gameObj.setAgentState(WhirledGameObject.AGENT_FAILED);

        // TODO: abort the game or let the client do it?
    }

    /**
     * Called privately by the ThaneGameController when anything in the agent's code domain
     * causes some lines of debug or error tracing to be spit out.
     */
    public void agentTrace (ClientObject caller, String[] trace)
    {
        // do nothing, subclasses may implement something interesting here
    }

    @Override // from GameManager
    public boolean allPlayersReady ()
    {
        return super.allPlayersReady() && ((_gameAgent == null) || _gameAgentReady);
    }

    @Override // from PlayManager
    public boolean isAgent (ClientObject caller)
    {
        return (_gameAgent != null) && (_gameAgent.clientOid == caller.getOid());
    }

    /**
     *  Make sure that the given caller can write to the data of the given player and resolve
     *  the playerId into a BodyObject. The player id may be 0, indicating the current
     *  player. Server agents may not use this value and clients may only use this value.
     **/
    public BodyObject validateWritePermission (ClientObject caller, int playerId)
        throws InvocationException
    {
        BodyObject body = checkWritePermission(caller, playerId);
        if (body != null) {
            return body;
        }
        throw new InvocationException(InvocationCodes.ACCESS_DENIED);
    }

    /**
     *  Make sure that the given caller can write to the data of the given player and resolve
     *  the playerId into a BodyObject. The player id may be 0, indicating the current
     *  player. Server agents may not use this value and clients may only use this value.
     **/
    @Override // from PlayManager
    public BodyObject checkWritePermission (ClientObject caller, int playerId)
    {
        if (isAgent(caller)) {
            return (playerId != 0) ? getOccupantById(playerId) : null;
        }
        return (playerId == 0) ? (BodyObject) caller : null;
    }

    @Override // from GameManager
    protected boolean shouldEndGame ()
    {
        // whirled games are never automatically ended, that's up to the per-game code to decide
        return false;
    }

    /**
     * Validate that the specified user has access to do things in the game.
     */
    protected void validateUser (ClientObject caller)
        throws InvocationException
    {
        // the server is always cool
        if (caller == null) {
            return;
        }

        // party games allow anyone to do things
        if (getMatchType() == GameConfig.PARTY) {
            return;
        }

        // regular players can do things only if seated
        if (caller instanceof BodyObject) {
            BodyObject body = (BodyObject)caller;
            if (getPlayerIndex(body.getVisibleName()) == -1) {
                throw new InvocationException(InvocationCodes.ACCESS_DENIED);
            }
            return;
        }

        // otherwise... this must be the agent
        requireAgent(caller);
    }

    /**
     * Require that the caller be the Agent before proceeding.
     */
    protected void requireAgent (ClientObject caller)
        throws InvocationException
    {
        if (!isAgent(caller)) {
            throw new InvocationException(InvocationCodes.ACCESS_DENIED);
        }
    }

    /**
     * Get the player's index, by id, or -1.
     */
    protected int getPlayerIndexById (int id)
    {
        return IntListUtil.indexOf(_playerOids, _idToOid.get(id));
    }

    /**
     * Get the specified player body by id.
     */
    protected BodyObject getPlayerById (int id)
    {
        // verify that they're a player
        switch (getMatchType()) {
        case GameConfig.PARTY:
            // all occupants are players in a party game
            break;

        default:
            if (-1 == getPlayerIndexById(id)) {
                return null; // not a player!
            }
            break;
        }

        return getOccupantById(id);
    }

    /**
     * Get the specified occupant body by Oid.
     */
    protected BodyObject getOccupantById (int id)
    {
        int oid = _idToOid.get(id);
        return (oid == -1) ? null : (BodyObject)_omgr.getObject(oid);
    }

    /**
     * Validate that the specified playerId is valid, and transform it into a persistent form.
     */
    protected int validatePlayerId (ClientObject caller, int playerId)
        throws InvocationException
    {
        if (playerId == 0) {
            if (isAgent(caller)) {
                throw new InvocationException(InvocationCodes.ACCESS_DENIED);
            }
            // transform it
            playerId = getPlayerPersistentId((BodyObject) caller);
        }

        if (getMatchType() == GameConfig.PARTY) {
            // it has to be someone here
            if (_idToOid.containsKey(playerId)) {
                return playerId; // success
            }

        } else {
            // it has to be one of the players, EVEN IF ABSENT, and not a watcher
            for (Name name : _gameObj.players) {
                if (name != null && playerId == getPlayerPersistentId(name)) {
                    return playerId; // success
                }
            }
        }

        // failure
        throw new InvocationException(InvocationCodes.ACCESS_DENIED);
    }

    /**
     * Flag this user as now being initailized. Done once the usercode has connected.
     */
    protected void setAsInitialized (BodyObject body)
    {
        updateOccupantInfo(body.getOid(), new OccupantInfo.Updater<WhirledGameOccupantInfo>() {
            public boolean update (WhirledGameOccupantInfo info) {
                if (info.initialized) {
                    return false;
                }
                info.initialized = true;
                return true;
            }
        });
    }

    @Override
    protected PlaceObject createPlaceObject ()
    {
        return new WhirledGameObject();
    }

    @Override
    protected void didInit ()
    {
        super.didInit();

        // initialize the appropriate turn delegate
        if (getMatchType() == GameConfig.PARTY) {
            WhirledPartyTurnDelegate del = new WhirledPartyTurnDelegate();
            _turnDelegate = del;
            addDelegate(del);
            del.didInit(_config);

        } else {
            WhirledSeatedTurnDelegate del = new WhirledSeatedTurnDelegate();
            _turnDelegate = del;
            addDelegate(del);
            del.didInit(_config);
        }
    }

    @Override
    protected void didStartup ()
    {
        super.didStartup();

        _gameObj = (WhirledGameObject) _plobj;

        // we need to retain a reference to this
        _propertySpaceHandler = new PropertySpaceHandler(_gameObj) {
            @Override protected void validateUser (ClientObject caller)
                throws InvocationException {
                WhirledGameManager.this.validateUser(caller);
            }
        };

        _messageHandler = new WhirledGameMessageHandler(_gameObj) {
            @Override protected void validateSender (ClientObject caller)
                throws InvocationException {
                WhirledGameManager.this.validateUser(caller);
            }

            @Override protected ClientObject getAudienceMember (int id)
                throws InvocationException {
                ClientObject target = null;
                if (id == SERVER_AGENT) {
                    if (_gameAgent != null && _gameAgent.clientOid != 0) {
                        target = (ClientObject)_omgr.getObject(_gameAgent.clientOid);
                    }
                } else {
                    target = getPlayerById(id);
                }
                if (target == null) {
                    throw new InvocationException("m.player_not_around");
                }
                return target;
            }

            @Override protected boolean isAgent (ClientObject caller) {
                return WhirledGameManager.this.isAgent(caller);
            }
        };

        _gameObj.setWhirledGameService(addDispatcher(new WhirledGameDispatcher(this)));
        _gameObj.setContentService(addDispatcher(new ContentDispatcher(this)));
        _gameObj.setPrizeService(addDispatcher(new PrizeDispatcher(this)));
        _gameObj.setPropertyService(
            addDispatcher(new PropertySpaceDispatcher(_propertySpaceHandler)));
        _gameObj.setMessageService(
            addDispatcher(new WhirledGameMessageDispatcher(_messageHandler)));
        _gameObj.setUserCookies(new DSet<UserCookie>());

        // register an agent for this game if required
        _gameAgent = createAgent();

        // set agent state to ready if the game doesn't require one
        if (_gameAgent == null) {
            _gameObj.setAgentState(WhirledGameObject.AGENT_READY);

        } else  {
            _bureauReg.startAgent(_gameAgent);
            // if the agent dies and we didn't destroy it, notify the client
            _gameAgent.addListener(new ObjectDeathListener() {
                public void objectDestroyed (ObjectDestroyedEvent event) {
                    if (_gameAgent != null) {
                        log.info("Game agent destroyed", "game", where());
                        _gameObj.setAgentState(WhirledGameObject.AGENT_FAILED);
                    }
                }
            });
        }
    }

    /**
     * Creates the agent for this game. An agent is optional server-side code for a game and is
     * managed by the {@link BureauRegistry}.
     *
     * @return the new agent object or null if the game does not require it
     */
    protected GameAgentObject createAgent ()
    {
        WhirledGameConfig cfg = (WhirledGameConfig)_gameconfig;
        GameDefinition def = cfg.getGameDefinition();
        String code = def.getServerMediaPath(getGameId());

        if (StringUtil.isBlank(code)) {
            return null;
        }

        GameAgentObject gameAgentObj = new GameAgentObject();
        gameAgentObj.gameOid = _gameObj.getOid();
        gameAgentObj.config = new ThaneGameConfig(getGameId(), def, cfg.params);
        gameAgentObj.bureauId = getBureauId();
        // We assume this is a thane/tamarin abc pacakage. TODO: do we need to check that?
        gameAgentObj.bureauType = BureauTypes.THANE_BUREAU_TYPE;
        gameAgentObj.code = code;
        if (StringUtil.isBlank(def.server)) {
            gameAgentObj.className = DEFAULT_SERVER_CLASS;
        } else {
            gameAgentObj.className = def.server;
        }
        return gameAgentObj;
    }

    /**
     * Get the id that will be assigned to this game's bureau, if any.
     */
    protected String getBureauId ()
    {
        WhirledGameConfig cfg = (WhirledGameConfig)_gameconfig;
        GameDefinition def = cfg.getGameDefinition();
        return BureauTypes.GAME_BUREAU_ID_PREFIX + def.getBureauId(getGameId());
    }

    @Override // from PlaceManager
    protected void bodyUpdated (OccupantInfo info)
    {
        super.bodyUpdated(info);

        // if the controller just disconnected, reassign control
        if (info.status == OccupantInfo.DISCONNECTED) {
            if (getPlayerPersistentId(info.username) == _gameObj.controllerId) {
                _gameObj.setControllerId(getControllerId());
            }

        } else if (_gameObj.controllerId == 0) {
            // if everyone in the room was disconnected and this client just reconnected, it becomes
            // the new controller
            _gameObj.setControllerId(getPlayerPersistentId(info.username));
        }
    }

    @Override // from GameManager
    protected void playersAllHere ()
    {
        switch (getMatchType()) {
        default:
        case GameConfig.SEATED_GAME:
            super.playersAllHere();
            break;

        case GameConfig.PARTY:
        case GameConfig.SEATED_CONTINUOUS:
            // the first time the first player calls playerReady() in a party or seated continuous
            // game, we start the game; after that it's up to the game to restart itself
            if (!_haveAutoStarted && _gameobj.state == WhirledGameObject.PRE_GAME) {
                _haveAutoStarted = true;
                startGame();
            }
            break;
        }
    }

    @Override
    protected void didShutdown ()
    {
        stopTickers();

        if (_gameAgent != null) {
            if (_gameAgent.isActive()) {
                _bureauReg.destroyAgent(_gameAgent);
            }
            _gameAgent = null;
        }

        super.didShutdown();
    }

    @Override
    protected void gameWillStart ()
    {
        // clear out the turn holder in case we're restarting
        _gameObj.setTurnHolder(null);

        super.gameWillStart();
    }

    @Override
    protected void gameDidStart ()
    {
        super.gameDidStart();

        // set our round id to 1 which will trigger the start of the first round
        _gameObj.setRoundId(1);
    }

    @Override
    protected void gameDidEnd ()
    {
        stopTickers();

        super.gameDidEnd();

        // Whirled games immediately reset to PRE_GAME after they end so that they can be
        // restarted if desired by having all players call playerReady() again
        _gameObj.setState(WhirledGameObject.PRE_GAME);
    }

    @Override
    protected void assignWinners (boolean[] winners)
    {
        if (_winners != null) {
            for (Name name : _winners) {
                int index = getPlayerIndex(name);
                if (index >= 0 && index < winners.length) {
                    winners[index] = true;
                }
            }
            _winners = null;
        }
    }

    /**
     * Stop and clear all tickers.
     */
    protected void stopTickers ()
    {
        if (_tickers != null) {
            for (Ticker ticker : _tickers.values()) {
                ticker.stop();
            }
            _tickers = null;
        }
    }

    /**
     * Returns the id of a player to whom to assign control of the game or zero if no players
     * qualify for control.
     */
    protected int getControllerId ()
    {
        for (OccupantInfo info : _gameObj.occupantInfo) {
            if (info.status != OccupantInfo.DISCONNECTED) {
                return getPlayerPersistentId(info.username);
            }
        }
        return 0;
    }

    @Override // from GameManager
    protected boolean needsNoShowTimer ()
    {
        // we are proxying for action script games here so have no idea if they can cope with
        // a premature start, don't do it.
        return false;
    }

    protected void resolveContentOwnership (BodyObject body, ResultListener<Void> listener)
    {
        // This base class knows nothing about ownership.
        listener.requestCompleted(null);
    }

    /**
     * A timer that fires message events to a game.
     */
    protected static class Ticker
    {
        /**
         * Create a Ticker.
         */
        public Ticker (String name, WhirledGameObject gameObj)
        {
            _name = name;
            // once we are constructed, we want to avoid calling methods on dobjs.
            _oid = gameObj.getOid();
            _omgr = gameObj.getManager();
        }

        public void start (int msOfDelay)
        {
            _value = 0;
            _interval.schedule(0, msOfDelay);
        }

        public void stop ()
        {
            _interval.cancel();
        }

        /**
         * The interval that does our work. Note well that this is not a 'safe' interval that
         * operates using a RunQueue.  This interval instead does something that we happen to know
         * is safe for any thread: posting an event to the dobj manager.  If we were using a
         * RunQueue it would be the same event queue and we would be posted there, wait our turn,
         * and then do the same thing: post this event. We just expedite the process.
         */
        protected Interval _interval = new Interval() {
            public void expired () {
                _omgr.postEvent(new MessageEvent(
                    _oid, WhirledGameObject.TICKER, new Object[] { _name, _value++ }));
            }
        };

        protected int _oid;
        protected DObjectManager _omgr;
        protected String _name;
        protected int _value;
    } // End: static class Ticker

    /** A nice casted reference to the game object. */
    protected WhirledGameObject _gameObj;

    /** We need a direct reference to this in order to set a property as a result of one of our
     * service calls ({@link #getFromcollection}). */
    protected PropertySpaceHandler _propertySpaceHandler;

    /** We need a direct reference to this in order to send a message as a result of one of our
     * service calls ({@link #getFromcollection}). */
    protected WhirledGameMessageHandler _messageHandler;

    /** Our turn delegate. */
    protected WhirledGameTurnDelegate _turnDelegate;

    /** The map of collections, lazy-initialized. */
    protected Map<String, List<byte[]>> _collections;

    /** The map of tickers, lazy-initialized. */
    protected Map<String, Ticker> _tickers;

    /** Maps player id to oid. */
    protected IntIntMap _idToOid = new IntIntMap();

    /** Tracks which cookies are currently being retrieved from the db. */
    protected ArrayIntSet _cookieLookups = new ArrayIntSet();

    /** The array of winners, non-null after a call to {@link #setWinners}. */
    protected Name[] _winners;

    /** Tracks whether or not we've auto-started a non-seated game. Unfortunately there's no way to
     * derive this from existing game state. */
    protected boolean _haveAutoStarted;

    /** The agent for this game or null if the game has no agent. */
    protected GameAgentObject _gameAgent;

    /** Set by <code>agentReady</code>. */
    protected boolean _gameAgentReady;

    /** Handles the storage of our user cookies. */
    @Inject protected GameCookieManager _cookMgr;

    /** Provides dictionary services. */
    @Inject protected DictionaryManager _dictMgr;

    /** Provides bureau services. */
    @Inject protected BureauRegistry _bureauReg;

    /** The minimum delay a ticker can have. */
    protected static final int MIN_TICKER_DELAY = 50;

    /** The maximum number of tickers allowed at one time. */
    protected static final int MAX_TICKERS = 3;
}
