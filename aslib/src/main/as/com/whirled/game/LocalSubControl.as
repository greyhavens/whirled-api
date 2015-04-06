//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game {

import flash.events.KeyboardEvent;

import flash.display.DisplayObject;

import flash.geom.Point;

import com.whirled.AbstractSubControl;

/**
 * Dispatched when a key is pressed when the game has focus.
 *
 * @eventType flash.events.KeyboardEvent.KEY_DOWN
 */
[Event(name="keyDown", type="flash.events.KeyboardEvent")]

/**
 * Dispatched when a key is released when the game has focus.
 *
 * @eventType flash.events.KeyboardEvent.KEY_UP
 */
[Event(name="keyUp", type="flash.events.KeyboardEvent")]

/**
 * Dispatched when the size of the game area changes.
 *
 * @eventType com.whirled.game.SizeChangedEvent.SIZE_CHANGED
 */
[Event(name="SizeChanged", type="com.whirled.game.SizeChangedEvent")]

/**
 * Dispatched if the game lobby is closed.
 *
 * @eventType com.whirled.game.LobbyClosedEvent.LOBBY_CLOSED
 */
[Event(name="LobbyClosed", type="com.whirled.game.LobbyClosedEvent")]

/**
 * Provides access to the 'local' game services. Do not instantiate this class yourself,
 * access it via GameControl.local.
 */
public class LocalSubControl extends AbstractSubControl
{
    /**
     * @private Constructed via GameControl.
     */
    public function LocalSubControl (parent :GameControl)
    {
        super(parent);
    }

    /**
     * @inheritDoc
     */
    override public function addEventListener (
        type :String, listener :Function, useCapture :Boolean = false,
        priority :int = 0, useWeakReference :Boolean = false) :void
    {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);

        switch (type) {
        case KeyboardEvent.KEY_UP:
        case KeyboardEvent.KEY_DOWN:
            if (hasEventListener(type)) { // ensure it was added
                callHostCode("alterKeyEvents_v1", type, true);
            }
            break;
        }
    }

    /**
     * @inheritDoc
     */
    override public function removeEventListener (
        type :String, listener :Function, useCapture :Boolean = false) :void
    {
        super.removeEventListener(type, listener, useCapture);

        switch (type) {
        case KeyboardEvent.KEY_UP:
        case KeyboardEvent.KEY_DOWN:
            if (!hasEventListener(type)) { // once it's no longer needed
                callHostCode("alterKeyEvents_v1", type, false);
            }
            break;
        }
    }

    /**
     * Get the size of the game area, expressed as a Point
     * (x = width, y = height).
     */
    public function getSize () :Point
    {
        return callHostCode("getSize_v1") as Point;
    }

    /**
     * Is the game being played in a "Whirled embed"?
     *
     * @return true if the game is being played on some 3rd-party site, or false if
     * on whirled.com or in the game testing environment.
     */
    public function isEmbedded () :Boolean
    {
        return Boolean(callHostCode("isEmbedded_v1"));
    }

    /**
     * Display a feedback chat message for the local player only, no other players
     * or observers will see it.
     */
    public function feedback (msg :String) :void
    {
        callHostCode("localChat_v1", msg);
    }

    /**
     * Run the specified text through the user's chat filter. This is optional, you can use
     * it to clean up user-entered text.
     *
     * @return the filtered text, or null if it was so bad it's gone.
     */
    public function filter (text :String) :String
    {
        return (callHostCode("filter_v1", text) as String);
    }

    /**
     * Return the headshot for the given occupant in the form of a DisplayObject.
     *
     * The objects are now *not* cached in the backend, so each request will return a brand
     * new headshot. You should save a reference to these in your game if you will be
     * re-using headshots, but now you may also get two headshots for the same player if you
     * want to display them in two places.
     *
     * The DisplayObject returned is always 80x60 pixels large. If the player's actual headshot
     * is smaller than 80x60, it will be centered inside the 80x60 area.
     *
     * Note: There is a weird flash security issue/bug that may prevent you from removing
     * this object from a parent. addChild(headshot) works, removeChild(headshot) works, but
     * calling getChildAt(index) or removeChildAt(index) using the index of the headshot will
     * throw a security error. Weird!
     *
     * @param occupantId the player for which to get a headshot.
     */
    public function getHeadShot (occupantId :int) :DisplayObject
    {
        return callHostCode("getHeadShot_v2", occupantId) as DisplayObject;
    }

    /**
     * Set the frame rate to use in your game. The default is 30fps, the
     * same frame rate used in whirled rooms. The actual frame rate may be bounded on the lower
     * end (for example, we may not let it go lower than 15fps) so that the rest of the user
     * interface doesn't become annoying or unusable.
     */
    public function setFrameRate (frameRate :Number = 30) :void
    {
        callHostCode("setFrameRate_v1", frameRate);
    }

    /**
     * Set the stage quality to use in your game. The default is MEDIUM, the same quality
     * used in whirled rooms.
     */
    public function setStageQuality (quality :String = "medium" /* == StageQuality.MEDIUM */) :void
    {
        callHostCode("setStageQuality_v1", quality);
    }

//    /**
//     * Set whether the rematch/replay button is shown at the end of the game. It is shown
//     * by default, but some games may not support rematching and so should hide the button.
//     *
//     * <b>Note:</b> this function changes local display only; other clients will not be affected.
//     */
//    public function setShowReplay (show :Boolean) :void
//    {
//        callHostCode("setShowReplay_v1", show);
//    }

    /**
     * Set a label to be shown above the occupants list in the game.
     * Set to null to remove the label.
     *
     * <b>Note:</b> this function changes local display only; other clients will not be affected.
     */
    public function setOccupantsLabel (label :String) :void
    {
        callHostCode("setOccupantsLabel_v1", label);
    }

    /**
     * Clear all the scores displayed in the occupants list.
     *
     * <b>Note:</b> this function changes local display only; other clients will not be affected.
     *
     * @param clearValue a value to set all the scores to, or null to not show anything.
     * @param sortValuesToo if true, also clear the sort values, returning the list
     * to the default sort order.
     */
    public function clearScores (clearValue :Object = null, sortValuesToo :Boolean = false) :void
    {
        callHostCode("clearScores_v1", clearValue, sortValuesToo);
    }

    /**
     * Set scores for seated players.
     *
     * <b>Note:</b> this function changes local display only; other clients will not be affected.
     *
     * @param scores an array of 'score' values that must correspond to the seated players.
     * The scores may be numeric or String and will be displayed after the player names.
     * @param sortValues an array of sorting values that must correpond to the seated players.
     * If not specified then the scoreValues are used to sort the occupants list.
     */
    public function setPlayerScores (scores :Array, sortValues :Array = null) :void
    {
        callHostCode("setPlayerScores_v1", scores, sortValues);
    }

    /**
     * Set score or sortValue values for occupants. You may want to call clearScores prior
     * to using this method to ensure that occupants that you don't specify are cleared out.
     * You may use this method to update the "score" and sorting value for any subset of
     * occupants in the game. You can update the score for one player having their occupantId
     * as the only key. You can even set a "score" for any watchers.
     *
     * <b>Note:</b> this function changes local display only; other clients will not be affected.
     *
     * @param scores an Object mapping occupantId to a score value (which may be a String or
     * numeric), or to a two-dimensional array containing the score value and the sortValue.
     */
    public function setMappedScores (scores :Object) :void
    {
        callHostCode("setMappedScores_v1", scores);
    }

    /**
     * Shows the Whirled page identified by the supplied token.
     *
     * @param token the token that identifies the page to be shown. This is <em>not</em> the full
     * URL, just the part after http://www.whirled.com/#. For example: passing "me" would show the
     * Me page. Passing "shop-l_5_343" would show the shop page for the Kawaii Knight avatar.
     *
     * @return true if the page was shown, false if it could not be shown for some reason.
     */
    public function showPage (token :String) :Boolean
    {
        return callHostCode("showPage_v1", token);
    }

    /**
     * Opens the web page for all the games at whirled. (Does nothing in the test environment)
     */
    public function showAllGames () :void
    {
        callHostCode("showAllGames_v1");
    }

    /**
     * Opens the game's multiplayer lobby on this player's machine. Please note this is only
     * meaningful for games that support multiplayer.
     *
     * @param multiplayerOnly Optional parameter: if this game supports both single- and
     * multi-player games, a true value will only show multiplayer options (create table
     * or join existing tables), and a false value will show the default
     * single- and multi-player options. Default value is true.
     */
    public function showGameLobby (multiplayerOnly :Boolean = true) :void
    {
        callHostCode("showGameLobby_v1", multiplayerOnly);
    }

    /**
     * Opens the web page for this game's shop. The game will be shrunk to sidebar width while the
     * game shop is showing.
     *
     * @param itemType the type of item to select by default. Valid constants are defined in
     * GameControl.
     * @param catalogId the catalog id of a specific item to show or 0 to display the overview page
     * of all items of the specified type.
     */
    public function showGameShop (itemType :String, catalogId :int = 0) :void
    {
        callHostCode("showGameShop_v1", itemType, catalogId);
    }

    /**
     * Instructs the game client to open the game invite page, allowing the player to invite friends
     * to play this game.
     * @param defmsg Default message that will be included along with the game's URL when sent
     * to the player's friends.
     * @param token Optional token that will be included on the URL and eventually passed back to
     * the game when an invited friend goes to the URL.  This allows the game to start in
     * a different state than usual.
     */
    public function showInvitePage (defmsg :String, token :String = "") :void
    {
        callHostCode("showInvitePage_v1", defmsg, token);
    }

    /**
     * Opens a popup displaying the trophies awarded by this game.
     */
    public function showTrophies () :void
    {
        callHostCode("showTrophies_v1");
    }

    /**
     * Retrieves the token, if any, that was used to launch the game.  If the player entered into
     * the game via a URL that contained a token (provided by the game via showInvitePage), this
     * will return that token, otherwise null. Note that the invitations are not managed securely,
     * it would be trivial for someone to modify a URL to specify a different token, so appropriate
     * checks should be made.
     */
    public function getInviteToken () :String
    {
        return callHostCode("getInviteToken_v1");
    }

    /**
     * Retrieves the ID of the member who invited the current player to this game (using the page
     * shown by <code>showInvitePage</code>. Returns 0 if the player did not start the game via an
     * invite link.
     */
    public function getInviterMemberId () :int
    {
        return callHostCode("getInviterMemberId_v1");
    }

    /**
     * @private
     */
    override public function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["dispatchEvent_v1"] = dispatchEvent; // for re-dispatching keyboard events
        o["sizeChanged_v1"] = sizeChanged_v1;
        o["lobbyClosed_v1"] = lobbyClosed_v1;
    }

    /**
     * Private method to generate a SizeChangedEvent.
     */
    private function sizeChanged_v1 (size :Point) :void
    {
        dispatchEvent(new SizeChangedEvent(size));
    }

    /**
     * Private method to generate a LobbyClosedEvent.
     */
    private function lobbyClosed_v1 () :void
    {
        dispatchEvent(new LobbyClosedEvent());
    }
}
}
