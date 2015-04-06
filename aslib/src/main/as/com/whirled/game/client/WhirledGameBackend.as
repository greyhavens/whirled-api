//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.utils.ByteArray;

import com.threerings.util.MessageBundle;
import com.threerings.util.Name;

import com.threerings.presents.dobj.MessageEvent;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.util.CrowdContext;

import com.whirled.game.data.BaseGameConfig;
import com.whirled.game.data.WhirledGameCodes;
import com.whirled.game.data.WhirledGameConfig;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.WhirledPlayerObject;

/**
 * Manages the backend of the game on the Flash client.
 */
public class WhirledGameBackend extends BaseGameBackend
{
    public function WhirledGameBackend (
        ctx :CrowdContext, gameObj :WhirledGameObject, ctrl :WhirledGameController)
    {
        _ctrl = ctrl; // set this first, needed in super().
        super(ctx, gameObj);

        (_ctx as CrowdContext).getChatDirector().addChatDisplay(this);

        // TODO: when we switch to player id instead of oid, do the right thing here
        var myId :int = _ctx.getClient().getClientObject().getOid();
        _ctx.getClient().getClientObject().addListener(
            _contentLner = new ContentListener(myId, getGameId(), this));
    }

    public function setGameView (gameView :GameBox) :void
    {
        _gameView = gameView;
        _stage = _gameView.stage;
        if (_stage == null) {
            _gameView.addEventListener(Event.ADDED_TO_STAGE, handleGrabStage);
        }
    }

    /**
     * Convenience function to get our name.
     */
    public function getUsername () :Name
    {
        var body :BodyObject = (_ctx.getClient().getClientObject() as BodyObject);
        return body.getVisibleName();
    }

    /**
     * Called by the WhirledGamePanel when the size of the game area has changed.
     */
    public function sizeChanged () :void
    {
        callUserCode("sizeChanged_v1", getSize_v1());
    }

    /**
     * Called when the game lobby is closed by the player.
     */
    public function lobbyClosed () :void
    {
        callUserCode("lobbyClosed_v1");
    }

    /** @inheritDoc */ // from BaseGameBackend
    override public function shutdown () :void
    {
        super.shutdown();

        (_ctx as CrowdContext).getChatDirector().removeChatDisplay(this);
        _ctx.getClient().getClientObject().removeListener(_contentLner);

        // once the usercode is incapable of calling setFrameRate and setStageQuality
        // ensure they're reset to defaults
        _stage.frameRate = 30;
        _stage.quality = StageQuality.MEDIUM;
    }

    /** @inheritDoc */ // from BaseGameBackend
    override public function messageReceived (event :MessageEvent) :void
    {
        var name :String = event.getName();
        if (WhirledGameObject.GAME_CHAT == name) {
            // chat sent by the game, route to our displayInfo
            localChat_v1(String(event.getArgs()[0]));

        } else if (WhirledGameObject.USER_MESSAGE_EXCLUDE_AGENT == name) {
            dispatchUserMessage(event); // since we ain't an agent

        } else {
            super.messageReceived(event);
        }
    }

    /** @inheritDoc */ // from BaseGameBackend
    override protected function notifyControllerUserCodeIsConnected (autoReady :Boolean) :void
    {
        _ctrl.userCodeIsConnected(autoReady);
    }

    /** @inheritDoc */ // from BaseGameBackend
    override protected function getConfig () :BaseGameConfig
    {
        return _ctrl.getPlaceConfig() as BaseGameConfig;
    }

    /** @inheritDoc */ // from BaseGameBackend
    override protected function countPlayerData (type :int, ident :String, playerId :int) :int
    {
        if (playerId != CURRENT_USER && playerId != getMyId_v1()) {
            throw new Error("Query of other user data not allowed");
        }
        var plobj :WhirledPlayerObject = _ctx.getClient().getClientObject() as WhirledPlayerObject;
        return plobj.countGameContent(getGameId(), type, ident);
    }

    /**
     * Used to report a typical framework-level message to the player. In the base class
     * this will end up using displayInfo(), but in Whirled will be overridden to use
     * the notifications.
     */
    protected function systemMessage (bundle :String, msg :String) :void
    {
        displayInfo(bundle, msg);
    }

    /**
     * Displays an info message to the player.
     */
    protected function displayInfo (bundle :String, msg :String, localType :String = null) :void
    {
        (_ctx as CrowdContext).getChatDirector().displayInfo(bundle, msg, localType);
    }

    /**
     * Displays a feedback message to the player. Default does nothing, so subclasses should
     * override.
     */
    protected function displayFeedback (bundle :String, msg :String) :void
    {
        (_ctx as CrowdContext).getChatDirector().displayFeedback(bundle, msg);
    }

    protected function handleGrabStage (event :Event) :void
    {
        var target :DisplayObject = event.currentTarget as DisplayObject;
        target.removeEventListener(Event.ADDED_TO_STAGE, handleGrabStage);
        _stage = target.stage;
    }

    /**
     * Handle key events on our container and pass them into the game.
     */
    protected function handleKeyEvent (evt :KeyboardEvent) :void
    {
        // dispatch a cloned copy of the event, so that it's safe
        _keyDispatcher(evt.clone());
    }

    /** @inheritDoc */ // from BaseGameBackend
    override protected function messageReceivedOnUserObject (event :MessageEvent) :void
    {
        var name :String = event.getName();
        if (name == WhirledGameObject.COINS_AWARDED_MESSAGE) {
            const args :Array = event.getArgs();
            var amount :int = int(args[0]);
            var percentile :int = int(args[1]);
            var forReal :Boolean = Boolean(args[2]);
            // We still use the old name for the dispatch method. Changing it would mean
            // testing to see if we need to use the new method or the old method and this is
            // all internal anyway, so I don't care.
            // Also: we coerce the result to a Boolean because pre-2008-05-29 classes will
            // return undefined and we want that to become false.
            var cancelled :Boolean = Boolean(callUserCode("flowAwarded_v1", amount, percentile));
            reportCoinsAwarded(amount, forReal, cancelled);
            // and add a little note if the coins aren't going to "stick" (never happen when
            // testing, but may happen in whirled).
            if (!forReal) {
                systemMessage(WhirledGameCodes.WHIRLEDGAME_MESSAGE_BUNDLE, "m.no_coins_dev");
            }

        } else {
            super.messageReceivedOnUserObject(event);
        }
    }

    /** @inheritDoc */ // from BaseGameBackend
    override protected function reportGameError (msg :String, err :Error = null) :void
    {
        super.reportGameError(msg, err);

        // report the message to chat to aid developer debugging
        (_ctx as CrowdContext).getChatDirector().displayAttention(null, MessageBundle.taint(msg));
    }

    /** @inheritDoc */ // from BaseGameBackend
    override protected function setUserCodeProperties (o :Object) :void
    {
        super.setUserCodeProperties(o);

        // here we would handle adapting old functions to a new version
        _keyDispatcher = (o["dispatchEvent_v1"] as Function);
    }

    /** @inheritDoc */ // from BaseGameBackend
    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        // GameControl
        o["focusContainer_v1"] = focusContainer_v1;

        // .local
        o["alterKeyEvents_v1"] = alterKeyEvents_v1;
        o["clearScores_v1"] = clearScores_v1;
        o["filter_v1"] = filter_v1;
        o["getHeadShot_v2"] = getHeadShot_v2;
        o["getSize_v1"] = getSize_v1;
        o["isEmbedded_v1"] = isEmbedded_v1;
        o["localChat_v1"] = localChat_v1;
        o["setMappedScores_v1"] = setMappedScores_v1;
        o["setOccupantsLabel_v1"] = setOccupantsLabel_v1;
        o["setPlayerScores_v1"] = setPlayerScores_v1;
        o["setFrameRate_v1"] = setFrameRate_v1;
        o["setShowReplay_v1"] = setShowReplay_v1;
        o["setStageQuality_v1"] = setStageQuality_v1;
        o["showPage_v1"] = showPage_v1;
        o["showAllGames_v1"] = showAllGames_v1;
        o["showGameLobby_v1"] = showGameLobby_v1;
        o["showGameShop_v1"] = showGameShop_v1;
        o["showTrophies_v1"] = showTrophies_v1;
        o["showInvitePage_v1"] = showInvitePage_v1;
        o["getInviteToken_v1"] = getInviteToken_v1;
        o["getInviterMemberId_v1"] = getInviterMemberId_v1;

        // .game
        o["isMyTurn_v1"] = isMyTurn_v1;
        o["playerReady_v1"] = playerReady_v1;

        // Old methods: backwards compatability
        o["getStageBounds_v1"] = getStageBounds_v1;
        o["getHeadShot_v1"] = getHeadShot_v1;
        o["setShowButtons_v1"] = setShowButtons_v1;
    }

    /**
     * We've already tried notifying usercode, now do a framework-level notification
     * of the coin awarding.
     */
    protected function reportCoinsAwarded (
        amount :int, forReal :Boolean, gameWantsMessageSuppressed :Boolean) :void
    {
        // we do nothing with forReal here, because this method only gets called if the
        // usercode didn't report the coin award itself. The forReal is handled elsewhere.
        if (!gameWantsMessageSuppressed) {
            systemMessage(WhirledGameCodes.WHIRLEDGAME_MESSAGE_BUNDLE,
                MessageBundle.tcompose("m.coins_awarded", amount));
        }
    }

    //---- GameControl -----------------------------------------------------

    protected function focusContainer_v1 () :void
    {
        validateConnected();
        _gameView.setFocus();
    }

    //---- .local ----------------------------------------------------------

    protected function alterKeyEvents_v1 (keyEventType :String, add :Boolean) :void
    {
        validateConnected();
        if (add) {
            _gameView.addEventListener(keyEventType, handleKeyEvent);
        } else {
            _gameView.removeEventListener(keyEventType, handleKeyEvent);
        }
    }

    protected function localChat_v1 (msg :String) :void
    {
        validateChat(msg);
        // The sendChat() messages will end up being routed through this method on each client.
        displayInfo(null, MessageBundle.taint(msg), WhirledGameCodes.USERGAME_CHAT_TYPE);
    }

    protected function filter_v1 (text :String) :String
    {
        return (_ctx as CrowdContext).getChatDirector().filter(text, null, true);
    }

    /**
     * Get the size of the game area.
     */
    protected function getSize_v1 () :Point
    {
        return new Point(_gameView.width, _gameView.height);
    }

    protected function isEmbedded_v1 () :Boolean
    {
        return false;
    }

    protected function setShowReplay_v1 (show :Boolean) :void
    {
        (_ctrl.getPlaceView() as WhirledGamePanel).setShowReplay(show);
    }

    protected function setFrameRate_v1 (frameRate :Number, quality :String = null) :void
    {
        validateConnected(); // so that the game can't futz the frame rate after we disconnect it!

        // then, let this throw whatever errors they might. Not our problem.
        _stage.frameRate = Math.max(frameRate, 15);

        // NOTE: originally the quality was specified as the second argument to setFrameRate.
        // To preserve backwards compatibility, the quality arg is now optional, but if specified
        // we must still let it work.
        if (quality != null) {
            setStageQuality_v1(quality);
        }
    }

    protected function setStageQuality_v1 (quality :String) :void
    {
        validateConnected(); // it's important not to let any still-running game code
        // alter the frame rate after we've "shut it off" and restored the whirled default quality

        // if quality is an invalid string, this might throw an error. Not our problem.
        _stage.quality = quality;
    }

    protected function setOccupantsLabel_v1 (label :String) :void
    {
        (_ctrl.getPlaceView() as WhirledGamePanel).getPlayerList().setLabel(label);
    }

    protected function clearScores_v1 (clearValue :Object = null,
        sortValuesToo :Boolean = false) :void
    {
        (_ctrl.getPlaceView() as WhirledGamePanel).getPlayerList().clearScores(
            clearValue, sortValuesToo);
    }

    protected function setPlayerScores_v1 (scores :Array, sortValues :Array = null) :void
    {
        (_ctrl.getPlaceView() as WhirledGamePanel).getPlayerList().setPlayerScores(
            scores, sortValues);
    }

    protected function setMappedScores_v1 (scores :Object) :void
    {
        (_ctrl.getPlaceView() as WhirledGamePanel).getPlayerList().setMappedScores(scores);
    }

    /**
     * Opens a Whirled page with the given token.  At this point there is no access to the rest of
     * Whirled, so display a message for testing purposes.  This will be overridden and completed
     * by a subclass with access to the rest of Whirled.
     */
    protected function showPage_v1 (token :String) :Boolean
    {
    	displayInfo(null, "showPage() failed because game is not connected to Whirled.");
        return false;
    }

    protected function showAllGames_v1 () :void
    {
        displayInfo(null, "showAllGames failed because game is not connected to Whirled.");
    }

    /**
     * Opens the game's shop to the correct section or item detail.  At this point there is no
     * access to the rest of Whirled, so display a message for testing purposes.  This will be
     * overridden and completed by a subclass with access to the rest of Whirled.
     */
    protected function showGameShop_v1 (itemType :String, catalogId :int = 0) :void
    {
        displayInfo(null, "Open game shop failed because game is not connected to Whirled.");
    }

    /**
     * Opens the game invite page with the given token.  At this point there is no access to the
     * rest of Whirled, so display a message for testing purposes.  This will be overridden and
     * completed by a subclass with access to the rest of Whirled.
     */
    protected function showInvitePage_v1 (defmsg :String, token :String = "") :void
    {
    	displayInfo(null, "Open game invite page failed because game is not connected to Whirled.");
    }

    /**
     * Retrieves the invite token.  At this point, there is no way to retrieve the token, so a
     * message is displayed indicating they must be in Whirled.
     */
    protected function getInviteToken_v1 () :String
    {
    	displayInfo(null, "Cannot retrieve invite token because game is not connected to Whirled.");
    	return null;
    }

    /**
     * Retrieves the ID of the member who invited the current used to play this game.  At this
     * point, there is no way to retrieve this ID, so a message is displayed indicating they must
     * be in Whirled.
     */
    protected function getInviterMemberId_v1 () :int
    {
    	displayInfo(null,
            "Cannot retrieve inviter's member ID because game is not connected to Whirled.");
        return 0;
    }

    /**
     * Display a feedback message, since we're not connected. This will be overridden and
     * completed by a subclass with access to the rest of Whirled.
     */
    protected function showGameLobby_v1 (multiplayer :Boolean) :void
    {
        displayInfo(null, "Would display a game lobby, but we're in the test environment.");
    }

    /**
     * Displays the trophies awarded by this game in a popup.  This will be overridden and
     * completed by a subclass with access to the rest of Whirled.
     */
    protected function showTrophies_v1 () :void
    {
        displayInfo(null, "Would display trophies popup, but we're in the test environment.");
    }

    protected function getHeadShot_v2 (occupantId :int) :DisplayObject
    {
        validateConnected();

        // in here, we just return a blank
        return new Thumbnail();
    }

    //---- .game -----------------------------------------------------------

    /** @inheritDoc */
    override protected function getMyId_v1 () :int
    {
        validateConnected();
        return nameToId(getUsername());
    }

    protected function playerReady_v1 () :void
    {
        if (isParty()) {
            // I'd like to throw an error, but some old games incorrectly call this and we don't
            // want to break them, so just log it here, but we throw an Error in newer versions of
            // GameSubControl.
            reportGameError("playerReady() is only applicable to seated games.");
            return;
        }
        _ctrl.playerIsReady();
    }

    protected function isMyTurn_v1 () :Boolean
    {
        validateConnected();
        return getUsername().equals(_gameObj.turnHolder);
    }

    //---- .game.seating ---------------------------------------------------

    /** @inheritDoc */
    override protected function getMyPosition_v1 () :int
    {
        validateConnected();
        return _gameObj.getPlayerIndex(
            (_ctx.getClient().getClientObject() as BodyObject).getVisibleName());
    }

    //---- backwards compatability -----------------------------------------

    /**
     * Backwards compatability. Added June 18, 2007, removed Oct 24, 2007. There
     * probably aren't many/any games that used this "in the wild", so we may be able to remove
     * this at some point.
     */
    protected function getStageBounds_v1 () :Rectangle
    {
        var size :Point = getSize_v1();
        return new Rectangle(0, 0, size.x, size.y);
    }

    /**
     * A backwards compatible method.
     */
    protected function getHeadShot_v1 (occupant :int, callback :Function) :void
    {
        // this callback was defined to return a Sprite, and Thumbnail is one, so this is safe
        callback(Sprite(getHeadShot_v2(occupant)), true);
    }

    /**
     * Backwards compatibility. setShowButtons() was removed Aug 9, 2008.
     */
    protected function setShowButtons_v1 (rematch :Boolean, back :Boolean) :void
    {
        setShowReplay_v1(rematch);
        // and discard the 'back' button preference.
    }

    protected var _ctrl :WhirledGameController;
    protected var _gameView :GameBox;
    protected var _stage :Stage;
    protected var _contentLner :ContentListener;

    /** The function on the GameControl which we can use to directly dispatch events to the
     * user's game. */
    protected var _keyDispatcher :Function;
}
}
