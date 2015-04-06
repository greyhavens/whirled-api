//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.util.CrowdContext;

/**
 * Wires up the necessary backend bits for testing games.
 */
public class TestGameController extends WhirledGameController
{
    // from WhirledGameController
    override protected function createBackend () :BaseGameBackend
    {
        return new TestGameBackend(_ctx, _gameObj, this);
    }

    // from PlaceController
    override protected function createPlaceView (ctx :CrowdContext) :PlaceView
    {
        return new TestGamePanel(ctx, this);
    }
}
}
