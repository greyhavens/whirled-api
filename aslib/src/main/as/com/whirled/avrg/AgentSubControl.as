//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;

import com.whirled.net.MessageSubControl;

/**
 * Provides AVR game clients a way to communicate to their server agent.
 */
public class AgentSubControl extends AbstractSubControl
    implements MessageSubControl
{
    /** @private */
    public function AgentSubControl (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    /**
     * Sends a message to the agent. The agent receives messages by adding a
     * <code>MESSAGE_RECEIVED</code> event listener to <code>GameSubControlServer</code>.
     * @see GameSubControlBase#event:MsgReceived
     */
    public function sendMessage (name :String, value :Object = null) :void
    {
        callHostCode("agent_sendMessage_v1", name, value);
    }

    /** @private */
    override public function setUserProps (o :Object) :void
    {
        super.setUserProps(o);
    }
}
}
