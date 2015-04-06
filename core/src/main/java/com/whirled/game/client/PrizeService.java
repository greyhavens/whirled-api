//
// $Id$

package com.whirled.game.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

/**
 * Provides services for awarding prizes and trophies.
 */
public interface PrizeService extends InvocationService
{
    /**
     * Awards the specified prize to the requesting player.
     */
    public void awardPrize (
        Client client, String ident, int playerId, InvocationListener listener);

    /**
     * Awards the specified trophy to the requesting player.
     */
    public void awardTrophy (
        Client client, String ident, int playerId, InvocationListener listener);
}
