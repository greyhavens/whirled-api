//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

/**
 * Defines actions, accessors and callbacks available to all Pets.
 */
public class PetControl extends ActorControl
{
    /**
     * Creates a controller for a Pet. The display object is the Pet's visualization.
     */
    public function PetControl (disp :DisplayObject)
    {
        super(disp);
    }

    /**
     * Send a chat message to the entire room. The chat message will be treated as if it
     * was typed in at the chat message box - it will be filtered.
     * TODO: Any action commands (e.g. /emote) should be handled appropriately.
     */
    public function sendChat (msg :String) :void
    {
        callHostCode("sendChatMessage_v1", msg);
    }

    /**
     * @private
     */
    override protected function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["receivedChat_v2"] = receivedChat_v2;
    }

    // the pet only reacts to chat when it has control
    override protected function receivedChat_v2 (entityId :String, message :String) :void
    {
        if (_hasControl) {
            super.receivedChat_v2(entityId, message);
        }
    }
}
}
