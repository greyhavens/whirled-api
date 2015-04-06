//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.crowd.client.PlaceController;
import com.whirled.game.client.ThaneGameController;

/**
 * A game config for a simple multiplayer thane whirled game.
 */
public class ThaneGameConfig extends BaseGameConfig
{
    public function ThaneGameConfig (gameId :int = 0, gameDef :GameDefinition = null)
    {
        super(gameId, gameDef);
    }

    /** @inheritDoc */
    // from BaseGameConfig
    override protected function createDefaultController () :PlaceController
    {
        return null; //new ThaneGameController();
    }
}
}
