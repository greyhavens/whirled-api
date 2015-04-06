//
// $Id$

package com.whirled.game.server;

import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;

import com.google.common.collect.Lists;
import com.samskivert.util.RandomUtil;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceConfig;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.parlor.game.server.GameManagerDelegate;

import com.threerings.parlor.turn.data.TurnGameObject;
import com.threerings.parlor.turn.server.TurnGameManager;

/**
 * A special turn delegate for party whirled games.
 */
public class WhirledPartyTurnDelegate extends GameManagerDelegate
    implements WhirledGameTurnDelegate
{
    @Override
    public void didInit (PlaceConfig config)
    {
        super.didInit(config);
        _tgmgr = (TurnGameManager) _plmgr;
    }

    @Override
    public void didStartup (PlaceObject plobj)
    {
        super.didStartup(plobj);
        _plobj = plobj;
        _turnGame = (TurnGameObject) plobj;
    }

    @Override
    public void bodyEntered (int bodyOid)
    {
        super.bodyEntered(bodyOid);

        if (_ordering != null) {
            _ordering.add(infoToId(_plobj.occupantInfo.get(bodyOid)));
        }
    }

    // NOTE: We can't remove the ordering id in bodyLeft since we can't map the oid to an id
    // after the body has left. So we leave it in _ordering, and it will be cleaned out
    // when next visited in setNextTurn().

    @Override
    public void gameDidEnd ()
    {
        super.gameDidEnd();

        // we can forget about any ordering now
        _ordering = null;
        _currentHolderId = 0;
    }

    // from WhirledGameTurnDelegate
    public void endTurn (int nextPlayerId)
    {
        _tgmgr.turnDidEnd();
        if (!_turnGame.isInPlay()) {
            _turnGame.setTurnHolder(null);
            _currentHolderId = 0;
            return;
        }

        // set up the ordering if we haven't done so already
        if (_ordering == null) {
            createOrdering();
        }

        // try using the player-specified value
        if (nextPlayerId != 0 && setNextTurn(nextPlayerId)) {
            return;
        }

        for (int playerId : _ordering) {
            if ((playerId != _currentHolderId) && setNextTurn(playerId)) {
                return;
            }
        }

        // we may get to the end without finding a new turn holder. Oh well!
    }

    /**
     * Set the next turn holder to the specified id, returning true on success.
     */
    protected boolean setNextTurn (int nextPlayerId)
    {
        BodyObject nextPlayer = ((WhirledGameManager) _plmgr).getOccupantById(nextPlayerId);
        if (nextPlayer == null) {
            _ordering.remove(nextPlayerId); // clean up the ordering, we can't remove on bodyLeft
            return false;
        }

        // if the last turn holder was still in there, move them to the end of the list now
        if (_ordering.remove(_currentHolderId)) {
            _ordering.add(_currentHolderId);
        }

        _tgmgr.turnWillStart();
        _turnGame.setTurnHolder(nextPlayer.getVisibleName());
        _tgmgr.turnDidStart();
        _currentHolderId = nextPlayerId;
        return true;
    }

    /**
     * Add all the occupant body oids to the _ordering list in a random order.
     */
    protected void createOrdering ()
    {
        List<Integer> list = Lists.newArrayListWithExpectedSize(_plobj.occupantInfo.size());
        for (OccupantInfo occInfo : _plobj.occupantInfo) {
            list.add(infoToId(occInfo));
        }

        // randomize the list
        Collections.shuffle(list, RandomUtil.rand);

        // and start out the ordering using that random order
        _ordering = new LinkedHashSet<Integer>(list);
    }

    protected int infoToId (OccupantInfo info)
    {
        return ((WhirledGameManager) _plmgr).getPlayerPersistentId(info.username);
    }

    /** The place object. */
    protected PlaceObject _plobj;

    /** The game manager for which we are delegating. */
    protected TurnGameManager _tgmgr;

    /** A reference to our game object. */
    protected TurnGameObject _turnGame;

    /** Tracks the turn ordering for occupants. Initialized only if turns are used by the game. */
    protected LinkedHashSet<Integer> _ordering;

    /** The oid of the current turn holder. */
    protected int _currentHolderId;
}
