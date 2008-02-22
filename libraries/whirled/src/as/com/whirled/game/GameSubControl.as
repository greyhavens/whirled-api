//
// $Id$

package com.whirled.game {

import com.whirled.AbstractSubControl;

/**
 * Dispatched when the controller changes for the game.
 *
 * @eventType com.whirled.game.StateChangedEvent.CONTROL_CHANGED
 */
[Event(name="ControlChanged", type="com.whirled.game.StateChangedEvent")]

/**
 * Dispatched when the game starts, usually after all players are present.
 *
 * @eventType com.whirled.game.StateChangedEvent.GAME_STARTED
 */
[Event(name="GameStarted", type="com.whirled.game.StateChangedEvent")]

/**
 * Dispatched when a round starts.
 *
 * @eventType com.whirled.game.StateChangedEvent.ROUND_STARTED
 */
[Event(name="RoundStarted", type="com.whirled.game.StateChangedEvent")]

/**
 * Dispatched when the turn changes in a turn-based game.
 *
 * @eventType com.whirled.game.StateChangedEvent.TURN_CHANGED
 */
[Event(name="TurnChanged", type="com.whirled.game.StateChangedEvent")]

/**
 * Dispatched when a round ends.
 *
 * @eventType com.whirled.game.StateChangedEvent.ROUND_ENDED
 */
[Event(name="RoundEnded", type="com.whirled.game.StateChangedEvent")]

/**
 * Dispatched when the game ends.
 *
 * @eventType com.whirled.game.StateChangedEvent.GAME_ENDED
 */
[Event(name="GameEnded", type="com.whirled.game.StateChangedEvent")]

/**
 * Dispatched when an occupant enters the game.
 *
 * @eventType com.whirled.game.OccupantChangedEvent.OCCUPANT_ENTERED
 */
[Event(name="OccupantEntered", type="com.whirled.game.OccupantChangedEvent")]

/**
 * Dispatched when an occupant leaves the game.
 *
 * @eventType com.whirled.game.OccupantChangedEvent.OCCUPANT_LEFT
 */
[Event(name="OccupantLeft", type="com.whirled.game.OccupantChangedEvent")]

/**
 * Dispatched when a user chats.
 *
 * @eventType com.whirled.game.UserChatEvent.USER_CHAT
 */
[Event(name="UserChat", type="com.whirled.game.UserChatEvent")]

/**
 * Access game-specific controls. Do not instantiate this class yourself.
 * Access it via GameControl.game.
 */
public class GameSubControl extends AbstractSubControl
{
    /** Cascading payout skews awards toward the winners by giving 50% of last place's payout to
     * first place, 25% to the next inner pair of opponents (third to second in a four player game,
     * for example), and so on. */
    public static const CASCADING_PAYOUT :int = 0;

    /** Winner takes all splits the total flow available to award to all players in the game among
     * those identified as winners at the end of the game. */
    public static const WINNERS_TAKE_ALL :int = 1;

    /** Each player receives a payout based only on their performance during the game and not
     * influenced by their relative ranking to one another. */
    public static const TO_EACH_THEIR_OWN :int = 2;

    /**
     * @private Constructed via GameControl.
     */
    public function GameSubControl (parent :GameControl)
    {
        super(parent);
    }

    /**
     * Access the 'seating' subcontrol.
     */
    public function get seating () :SeatingSubControl
    {
        // TODO: this should return null for PARTY games
        return _seatingCtrl;
    }

    /**
     * Get any game-specific configurations that were set up in the lobby.
     *
     * @return an Object containing config names mapping to their values.
     */
    public function getConfig () :Object
    {
        return _gameConfig; 
    }

    /**
     * Returns the set of level packs available to this game as an array of objects with the
     * following properties:
     *
     * <pre>
     * ident - string identifier of level pack
     * name - human readable name of level pack
     * mediaURL - URL for level pack content
     * premium - boolean indicating that content is premium or not
     * </pre>
     *
     * This will contain all free level packs that are registered for this game as well as the
     * premium level packs owned by this client's player.
     */
    public function getLevelPacks () :Array
    {
        return (callHostCode("getLevelPacks_v1") as Array);
    }

    /**
     * Returns the set of all item packs available to this game as an array of objects with the
     * following properties:
     *
     * <pre>
     * ident - string identifier of item pack
     * name - human readable name of item pack
     * mediaURL - URL for item pack content
     * </pre>
     */
    public function getItemPacks () :Array
    {
        return (callHostCode("getItemPacks_v1") as Array);
    }

    /** 
     * Send a system chat message that will be seen by everyone in the game room,
     * even observers.
     */
    public function systemMessage (msg :String) :void
    {
        callHostCode("sendChat_v1", msg);
    }

    /**
     * If the game was not configured to auto-start, all clients must call this function to let the
     * server know that they are ready, at which point the game will be started. Once a game is
     * over, all clients can call this function again to start a new game.
     */
    public function playerReady () :void
    {
        callHostCode("playerReady_v1");
    }

    /**
     * Returns the player ids of all occupants in the game room: players and watchers.
     */
    public function getOccupantIds () :Array /* of playerId */
    {
        return (callHostCode("getOccupants_v1") as Array);
    }

    /**
     * Get the display name of the specified occupant.  Two players may have the same name: always
     * use playerId to purposes of identification and comparison. The name is for display
     * only. Will be null is the specified playerId is not present.
     */
    public function getOccupantName (playerId :int) :String
    {
        return String(callHostCode("getOccupantName_v1", playerId));
    }

    /**
     * Returns this client's player id.
     */
    public function getMyId () :int
    {
        return int(callHostCode("getMyId_v1"));
    }
    
    /**
     * Returns true if we are in control of this game. False if another client is in control.
     */
    public function amInControl () :Boolean
    {
        return getControllerId() == getMyId();
    }
    
    /**
     * Returns the player id of the client that is in control of this game.
     */
    public function getControllerId () :int
    {
        return int(callHostCode("getControllerId_v1"));
    }
    
    /**
     * Returns the player id of the current turn holder, or 0 if it's nobody's turn.
     */
    public function getTurnHolderId () :int
    {
        return int(callHostCode("getTurnHolder_v1"));
    }

    /**
     * Returns the current round number. Rounds start at 1 and increase if the game calls {@link
     * #endRound} with a next round timeout. Between rounds, it returns a negative number,
     * corresponding to the negation of the round that just ended.
     */
    public function getRound () :int
    {
        return int(callHostCode("getRound_v1"));
    }

    /**
     * A convenience method to just check if it's our turn.
     */
    public function isMyTurn () :Boolean
    {
        return Boolean(callHostCode("isMyTurn_v1"));
    }

    /**
     * Is the game currently in play?
     */
    public function isInPlay () :Boolean
    {
        return Boolean(callHostCode("isInPlay_v1"));
    }

    /**
     * Start the next player's turn. If a playerId is specified, that player's turn will be
     * next. Otherwise the turn will be assigned randomly the first time, after that following
     * the "natural" turn order. In a seated game, the natural order follows the seating order.
     * In a party game, the natural order is to give the turn to the player that has been
     * around the longest without getting a turn.
     */
    public function startNextTurn (nextPlayerId :int = 0) :void
    {
        callHostCode("startNextTurn_v1", nextPlayerId);
    }

    /**
     * Ends the current round. If nextRoundDelay is greater than zero, the next round will be
     * started in the specified number of seconds, otherwise no next round will be started.  This
     * method should not be called at the end of the last round, instead <code>endGame()</code>
     * should be called.
     */
    public function endRound (nextRoundDelay :int = 0) :void
    {
        callHostCode("endRound_v1", nextRoundDelay);
    }

    /**
     * Ends the game, declaring which players are the winners (if players tie, more than one player
     * can be declared a winner. In addition to ending the game, this method awards flow and
     * updates players ratings.
     *
     * <p> Flow is awarded based on the supplied payout type, either CASCADING_PAYOUT or
     * WINNERS_TAKE_ALL. In the case of WINNERS_TAKE_ALL, the losers will have all of their
     * individual flow payouts combined into a pool and that pool will be evenly divided among the
     * winners and added to their respective individual flow payouts. In the case of
     * CASCADING_PAYOUT, the losers will only have 50% of their individual flow payouts given to
     * the winners. </p>
     *
     * <p> If flow is awarded, a FLOW_AWARDED event will be dispatched <em>before</em> the
     * GAME_ENDED event is dispatched informing the client that the game has ended. </p>
     *
     * <p> Players' ratings will also be updated using the Elo algorigthm wherein each player is
     * rated against the average ratings of the players that the defeated or were defeated by.  In
     * a two player game this degenerates into the standard Elo algorithm. </p>
     *
     * @see http://en.wikipedia.org/wiki/ELO_rating_system
     */
    public function endGameWithWinners (winnerIds :Array, loserIds :Array, payoutType :int) :void
    {
        callHostCode("endGameWithWinners_v1", winnerIds, loserIds, payoutType);
    }

    /**
     * Ends the game, reporting the scores earned by each player in the game, awarding flow
     * according to the specified strategy and updating player ratings.
     *
     * <p> Flow is awarded based on the supplied payout type, either CASCADING_PAYOUT,
     * WINNERS_TAKE_ALL or TO_EACH_THEIR_OWN. In the case of WINNERS_TAKE_CALL, the highest scoring
     * player or players will be considered the winner(s) and in the case of CASCADING_PAYOUT,
     * players will be ranked according to their scores, higher scores being considered better. </p>
     *
     * <p> If flow is awarded, a FLOW_AWARDED event will be dispatched <em>before</em> the
     * GAME_ENDED event is dispatched informing the client that the game has ended. </p>
     *
     * <p> Both rating and a player's flow payout will be adjusted based on their score. Whirled
     * will track every score reported by your game for its entire existence and will convert newly
     * reported scores to a percentile value between 0 and 99 (inclusive) indicating the percentage
     * of scores in the entire score history that are below the reported score. That percentile
     * ranking will be used to adjust the players rating as well as to determine their individual
     * flow payout. </p>
     *
     * <p> Note that scores must be integers >= 0 and higher scores are considered better, so if
     * your game naturally operates with scores where lower is better (elapsed time in a racing
     * game, for example), then you must convert your score to a positive integer by, for example,
     * subtracting your score from a hypothentical worse possible score. For example: </p>
     *
     * <p><code>score = Math.max(WORST_POSSIBLE_TIME - actualTime, 1)</code></p>
     *
     * <p> Note that if a game is ended with all players scores equal of zero, it will be assumed
     * that the players in question abandoned the game and no flow will be paid out, nor will their
     * ratings be updated. </p>
     */
    public function endGameWithScores (playerIds :Array, scores :Array /* of int */,
        payoutType :int) :void
    {
        callHostCode("endGameWithScores_v1", playerIds, scores, payoutType);
    }

    /**
     * A convenience function for ending a single player game with the supplied score. This is
     * equivalent to: <code>endGameWithScores([ getMyId() ], [ score ], TO_EACH_THEIR_OWN)</code>.
     *
     * <p> Note that if a single player game is ended with a score of zero, it will be assumed that
     * the player in question abandoned the game and no flow will be paid out, nor will their
     * rating be updated. </p>
     */
    public function endGameWithScore (score :int) :void
    {
        endGameWithScores([ getMyId() ], [ score ], TO_EACH_THEIR_OWN);
    }

    /**
     * Requests to start the game again in the specified number of seconds. This should only be
     * used for party games. Seated table games should have each player report that they are ready
     * again and the game will automatically start.
     */
    public function restartGameIn (seconds :int) :void
    {
        callHostCode("restartGameIn_v1", seconds);
    }

    /** @private */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["controlDidChange_v1"] = controlDidChange_v1;
        o["turnDidChange_v1"] = turnDidChange_v1;
        o["gameStateChanged_v1"] = gameStateChanged_v1;
        o["roundStateChanged_v1"] = roundStateChanged_v1;
        o["occupantChanged_v1"] = occupantChanged_v1;
        o["userChat_v1"] = userChat_v1;
    }

    /** @private */
    override protected function gotHostProps (o :Object) :void
    {
        super.gotHostProps(o);

        _gameConfig = o.gameConfig;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            // TODO
            // party games shouldn't have this, but it needs to be created before we
            // we even know what type of game we are. Maybe after we find out we destroy it??
            _seatingCtrl = new SeatingSubControl(_parent, this)
        ];
    }

    /**
     * Private method to post a StateChangedEvent.
     */
    private function controlDidChange_v1 () :void
    {
        dispatch(new StateChangedEvent(StateChangedEvent.CONTROL_CHANGED));
    }

    /**
     * Private method to post a StateChangedEvent.
     */
    private function turnDidChange_v1 () :void
    {
        dispatch(new StateChangedEvent(StateChangedEvent.TURN_CHANGED));
    }

    /**
     * Private method to post a StateChangedEvent.
     */
    private function gameStateChanged_v1 (started :Boolean) :void
    {
        dispatch(new StateChangedEvent(started ? StateChangedEvent.GAME_STARTED
                                               : StateChangedEvent.GAME_ENDED));
    }

    /**
     * Private method to post a StateChangedEvent.
     */
    private function roundStateChanged_v1 (started :Boolean) :void
    {
        dispatch(new StateChangedEvent(started ? StateChangedEvent.ROUND_STARTED
                                               : StateChangedEvent.ROUND_ENDED));
    }

    /**
     * Private method to post a OccupantEvent.
     */
    private function occupantChanged_v1 (occupantId :int, player :Boolean, enter :Boolean) :void
    {
        dispatch(new OccupantChangedEvent(
            enter ? OccupantChangedEvent.OCCUPANT_ENTERED
                  : OccupantChangedEvent.OCCUPANT_LEFT, occupantId, player));
    }

    /**
     * Private method to post a UserChatEvent.
     */
    private function userChat_v1 (speaker :int, message :String) :void
    {
        dispatch(new UserChatEvent(speaker, message));
    }

    /** Contains any custom game configuration data. @private */
    protected var _gameConfig :Object = {};

    /** The seating sub-control. @private */
    protected var _seatingCtrl :SeatingSubControl;
}
}