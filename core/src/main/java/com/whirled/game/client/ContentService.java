//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

import com.whirled.game.data.WhirledPlayerObject;
import com.whirled.game.data.GameContentOwnership;

/**
 * Handles content-related game services.
 */
public interface ContentService extends InvocationService
{
    /**
     * Requests to purchase the specified item pack on behalf of the specified player. If the
     * request is processed, there will be a count-increment in or addition of the appropriate
     * {@link GameContentOwnership} record in the player's {@link WhirledPlayerObject#gameContent}
     * set.
     *
     * @param playerId the id of the player for whom to purchase the pack. If this request comes
     * from the client, this value is ignored in favor of the id of the requesting client.
     */
    public void purchaseItemPack (
        Client client, int playerId, String ident, InvocationListener listener);

    /**
     * Requests to consume the specified item pack. If the request is processed, there will be a
     * count-reduction in or removal of the appropriate {@link GameContentOwnership} record in the
     * player's {@link WhirledPlayerObject#gameContent} set.
     *
     * @param playerId the id of the player for whom to consume the pack. If this request comes
     * from the client, this value is ignored in favor of the id of the requesting client.
     */
    public void consumeItemPack (
        Client client, int playerId, String ident, InvocationListener listener);
}
