//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

import flash.utils.setTimeout;
import com.threerings.bureau.data.AgentObject;
import com.threerings.bureau.client.Agent;
import com.threerings.bureau.client.BureauDirector;
import com.whirled.bureau.data.GameAgentObject;
import com.whirled.bureau.util.WhirledBureauContext;

/** Implements the bureau director for whirled. Creates our whirled agent types. */
public class WhirledBureauDirector extends BureauDirector
{
    /** Creates a new director. */
    public function WhirledBureauDirector (ctx :WhirledBureauContext)
    {
        super(ctx);
    }

    /** @inheritDoc */
    // from BureauDirector
    public override function fatalError (message :String) :void
    {
        var output :Boolean = false;
        for each (var agent :Agent in _agents.values()) {
            if (agent is BaseGameAgent) {
                BaseGameAgent(agent).outputToUserCode("Fatal error: " + message);
                output = true;
            }
        }

        if (!output) {
            super.fatalError(message);
            return;
        }

        // Call the super method a bit later, it would be very helpful for the user to be able to
        // see the error
        setTimeout(function () :void {
            callSuperFatalError(message);
        }, 1000);
    }

    // from BureauDirector
    protected override function createAgent (agentObj :AgentObject) :Agent
    {
        if (agentObj is GameAgentObject) {
            return new WhirledGameAgent(_ctx as WhirledBureauContext);
        }

        throw new Error("Unknown type");
    }

    protected function callSuperFatalError (message :String) :void
    {
        super.fatalError(message);
    }
}

}
