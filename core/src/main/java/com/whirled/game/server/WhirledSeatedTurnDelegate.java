//
// $Id$

package com.whirled.game.server;

import com.samskivert.util.ListUtil;

import com.threerings.crowd.data.BodyObject;

import com.threerings.parlor.turn.server.TurnGameManagerDelegate;

/**
 * A special turn delegate for seated whirled games.
 */
public class WhirledSeatedTurnDelegate extends TurnGameManagerDelegate
    implements WhirledGameTurnDelegate
{
    // from WhirledGameTurnDelegate
    public void endTurn (int nextPlayerId)
    {
        _nextPlayerId = nextPlayerId;
        endTurn();
    }

    @Override
    protected void setFirstTurnHolder ()
    {
        // make it nobody's turn
        _turnIdx = -1;
    }

    @Override
    protected void setNextTurnHolder ()
    {
        // if the user-supplied value seems to make sense, use it!
        if (_nextPlayerId != 0) {
            // clear out _nextPlayerId.
            int nextId = _nextPlayerId;
            _nextPlayerId = 0;

            BodyObject nextPlayer = ((WhirledGameManager) _plmgr).getPlayerById(nextId);
            if (nextPlayer != null) {
                int index = ListUtil.indexOf(_turnGame.getPlayers(), nextPlayer.getVisibleName());
                if (index != -1) {
                    _turnIdx = index;
                    return;
                }
            }
        }
        
        // Otherwise, if it's nobody's turn- randomly pick a turn holder
        if (_turnIdx == -1) {
            assignTurnRandomly();
            return;
        }

        // otherwise, do the default behavior
        super.setNextTurnHolder();
    }

    /** An override next turn holder, or 0. */
    protected int _nextPlayerId;
}
