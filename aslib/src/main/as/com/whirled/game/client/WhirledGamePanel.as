//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.display.Loader;

import mx.containers.Canvas;

import com.threerings.util.Name;
import com.threerings.util.Log;

import com.threerings.media.MediaContainer;

import com.threerings.flex.CommandButton;
import com.threerings.flex.FlexUtil;

import com.threerings.presents.dobj.AttributeChangeAdapter;
import com.threerings.presents.dobj.AttributeChangedEvent;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.parlor.game.data.GameConfig;

import com.whirled.game.data.WhirledGameCodes;
import com.whirled.game.data.WhirledGameConfig;
import com.whirled.game.data.WhirledGameObject;

public class WhirledGamePanel extends Canvas
    implements PlaceView
{
    /** The minimum guaranteed width for a game. */
    public static const GAME_WIDTH :int = 700;

    /** The minimum guaranteed height for a game. */
    public static const GAME_HEIGHT :int = 500;

    public function WhirledGamePanel (ctx :CrowdContext, ctrl :WhirledGameController)
    {
        _ctx = ctx;
        _ctrl = ctrl;

        _rematch = new CommandButton(null, handleRematchClicked);
        _rematch.toggle = true;

        _playerList = createPlayerList();
    }

    // from PlaceView
    public function willEnterPlace (plobj :PlaceObject) :void
    {
        // Important: The playerList needs to be a listener before the backend..
        _playerList.startup(plobj);

        _gameObj = (plobj as WhirledGameObject);

        const cfg :WhirledGameConfig = (_ctrl.getPlaceConfig() as WhirledGameConfig);
        const url :String = cfg.getGameDefinition().getMediaPath(cfg.getGameId());
        _gameContainer = createGameContainer();
        _gameView = new GameBox(url, _gameContainer);
        configureGameView(_gameView);
        (_ctrl.backend as WhirledGameBackend).setGameView(_gameView);
        addChild(_gameView);

        _rematch.label = getRematchLabel(plobj);
        checkGameOverDisplay();

        // Crank up the media loader only after the agent is ready
        if (_gameObj.agentState == WhirledGameObject.AGENT_READY) {
            initiateLoading();

        } else if (_gameObj.agentState == WhirledGameObject.AGENT_PENDING) {
            var agentStateListener :AttributeChangeAdapter;
            agentStateListener = new AttributeChangeAdapter(
                function (event :AttributeChangedEvent) :void {
                    if (event.getName() == WhirledGameObject.AGENT_STATE) {
                        if (event.getValue() == WhirledGameObject.AGENT_READY) {
                            initiateLoading();
                            _gameObj.removeListener(agentStateListener);
                        } else if (event.getValue() == WhirledGameObject.AGENT_FAILED) {
                            reportAgentFailure();
                            _gameObj.removeListener(agentStateListener);
                        }
                    }
                });
            _gameObj.addListener(agentStateListener);

        } else if (_gameObj.agentState == WhirledGameObject.AGENT_FAILED) {
            reportAgentFailure();

        } else {
            Log.getLog(this).warning("Unexpected agent state", "state", _gameObj.agentState);
            initiateLoading();
        }
    }

    // from PlaceView
    public function didLeavePlace (plobj :PlaceObject) :void
    {
        _playerList.shutdown();

        _gameContainer.shutdown(true);
        removeChild(_gameView);
    }

    /**
     * Get the controller.
     */
    public function getController () :WhirledGameController
    {
        return _ctrl;
    }

    /**
     * Get a handle on the player list.
     */
    public function getPlayerList () :GamePlayerList
    {
        return _playerList;
    }

    /**
     * Set whether or not we would show the replay button, if it were time to show it.
     */
    public function setShowReplay (show :Boolean) :void
    {
        _showRematch = show;
        checkGameOverDisplay();
    }

    /**
     * Called by the controller and internally to update the visibility of the rematch button
     * and any game-over display that might be hosting it.
     */
    public function checkGameOverDisplay () :void
    {
        const gameOver :Boolean = !_gameObj.isInPlay() && (_gameObj.roundId != 0);
        if (gameOver) {
            const canRematch :Boolean = _showRematch && !_ctrl.isParty() && playersAllHere();
            FlexUtil.setVisible(_rematch, canRematch);

        } else {
            // reset the button
            _rematch.selected = false;
            _rematch.enabled = true;
        }
        displayGameOver(gameOver);
    }

    /**
     * Called as soon as the game's agent is ready to initiate loading.
     */
    protected function initiateLoading () :void
    {
        _gameView.initiateLoading();
        _ctrl.backend.setSharedEvents(
            Loader(_gameContainer.getMedia()).contentLoaderInfo.sharedEvents);
    }

    /**
     * Called if the agent was aborted or could not be started.
     */
    protected function reportAgentFailure () :void
    {
        _ctx.getChatDirector().displayAttention(WhirledGameCodes.WHIRLEDGAME_MESSAGE_BUNDLE,
                                                "e.agent_failed");
    }

    /**
     * Show or hide some sort of game-over display.
     */
    protected function displayGameOver (gameOver :Boolean) :void
    {
        // nothing in the base class
    }

    /**
     * Handle rematch being clicked. We prevent it from being clicked more than once.
     */
    protected function handleRematchClicked (... ignored) :void
    {
        _rematch.enabled = false;
        _ctrl.playerIsReady();
    }

    /**
     * Return true if every player in the players array is present.
     */
    protected function playersAllHere () :Boolean
    {
        var occs :Array = _gameObj.occupantInfo.toArray();
        for each (var name :Name in _gameObj.players) {
            if (name != null) {
                var found :Boolean = false;
                for each (var occInfo :OccupantInfo in occs) {
                    if (name.equals(occInfo.username)) {
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * Get the button labels for the rematch button.
     */
    protected function getRematchLabel (plobj :PlaceObject) :String
    {
        throw new Error("abstract");
    }

    override protected function updateDisplayList (uw :Number, uh :Number) :void
    {
        super.updateDisplayList(uw, uh);

        var backend :WhirledGameBackend = _ctrl.backend as WhirledGameBackend;
        if (backend != null) {
            backend.sizeChanged();
        }
    }

    /**
     * Creates the player list we'll use to display player names and scores.
     */
    protected function createPlayerList () :GamePlayerList
    {
        return new GamePlayerList();
    }

    protected function createGameContainer () :MediaContainer
    {
        return new MediaContainer();
    }

    protected function configureGameView (view :GameBox) :void
    {
        view.percentWidth = 100;
        view.percentHeight = 100;
    }

    protected var _ctx :CrowdContext;
    protected var _ctrl :WhirledGameController;
    protected var _gameView :GameBox;
    protected var _gameContainer :MediaContainer;
    protected var _gameObj :WhirledGameObject;

    /** The player list. */
    protected var _playerList :GamePlayerList;

    /** Some buttons. */
    protected var _rematch :CommandButton;

    /** Would we want to show the rematch button, if the game was over? */
    protected var _showRematch :Boolean = true;
}
}
