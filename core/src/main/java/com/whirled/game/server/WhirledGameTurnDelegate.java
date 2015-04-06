//
// $Id$

package com.whirled.game.server;

public interface WhirledGameTurnDelegate
{
    /**
     * Start the next turn, specifying the id of the next turn holder or 0.
     */
    public void endTurn (int nextTurnHolderId);
}
