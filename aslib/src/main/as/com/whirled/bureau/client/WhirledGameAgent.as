//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

import com.whirled.bureau.util.WhirledBureauContext;

import com.whirled.bureau.data.GameAgentObject;

import com.whirled.game.client.ThaneGameController;

import com.whirled.game.data.WhirledGameObject;

/** The container for a user's game control code. */
public class WhirledGameAgent extends BaseGameAgent
{
    public function WhirledGameAgent (ctx :WhirledBureauContext)
    {
        super(ctx);
    }

    /** Access the agent object, casted to a game agent object. */
    protected function get gameAgentObj () :GameAgentObject
    {
        return _agentObj as GameAgentObject;
    }

    /** @inheritDoc */
    // from BaseGameAgent
    override protected function getGameOid () :int
    {
        return gameAgentObj.gameOid;
    }

    /** @inheritDoc */
    // from BaseGameAgent
    override protected function createController () :GameAgentController
    {
        var ctrl :ThaneGameController = new ThaneGameController();
        ctrl.init(_ctx, _gameObj as WhirledGameObject, this, gameAgentObj.config);
        return ctrl;
    }
}
}
