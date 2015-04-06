//
// $Id$

package com.whirled.party {

import com.threerings.util.Map;
import com.threerings.util.Maps;

import com.whirled.AbstractControl;
import com.whirled.ControlEvent;

/**
 * @private
 */
public class PartyHelper
{
    /** @private */
    public function PartyHelper (host :AbstractControl)
    {
        _host = host;
    }

    /** @private */
    public function getParty (partyId :int, funcs :Object) :PartySubControl
    {
        var ctrl :PartySubControl = _parties.get(partyId);
        if (ctrl == null) {
            ctrl = new PartySubControl(_host, partyId);
            ctrl.gotHostProps(funcs);
            _parties.put(partyId, ctrl);
        }
        return ctrl;
    }

    /** @private */
    public function setUserProps (o :Object) :void
    {
        o["game_partyEntered_v1"] = partyEntered_v1;
        o["game_partyLeft_v1"] = partyLeft_v1;
        o["party_playerEntered_v1"] = party_playerEntered_v1;
        o["party_playerLeft_v1"] = party_playerLeft_v1;
        o["party_leaderChanged_v1"] = party_leaderChanged_v1;
    }

    /** @private */
    protected function partyEntered_v1 (partyId :int, ... rest) :void
    {
        _host.dispatchEvent(new ControlEvent(PartySubControl.PARTY_ENTERED, null, partyId));
    }

    protected function partyLeft_v1 (partyId :int, ... rest) :void
    {
        _host.dispatchEvent(new ControlEvent(PartySubControl.PARTY_LEFT, null, partyId));
    }

    /** @private */
    protected function party_playerEntered_v1 (partyId :int, playerId :int, ... rest) :void
    {
        dispatchParty(partyId, PartySubControl.PLAYER_ENTERED_PARTY, null, playerId);
    }

    /** @private */
    protected function party_playerLeft_v1 (partyId :int, playerId :int, ... rest) :void
    {
        dispatchParty(partyId, PartySubControl.PLAYER_LEFT_PARTY, null, playerId);
    }

    /** @private */
    protected function party_leaderChanged_v1 (partyId :int, playerId :int, ... rest) :void
    {
        dispatchParty(partyId, PartySubControl.PARTY_LEADER_CHANGED, null, playerId);
    }

    /**
     * Internal convenience function for dispatching events on a PartySubControl.
     * @private
     */
    protected function dispatchParty (partyId :int, event :String, name :String, arg :Object) :void
    {
        var ctrl :PartySubControl = _parties.get(partyId);
        if (ctrl != null) {
            ctrl.dispatchEvent(new ControlEvent(event, name, arg));
        }
    }

    /** @private */
    protected var _host :AbstractControl;

    /** @private */
    protected var _parties :Map = Maps.newBuilder(int).makeWeakValues().build();
}
}
