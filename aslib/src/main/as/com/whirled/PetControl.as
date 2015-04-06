//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

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
     * Get the memberId of this pet's owner.
     * This is just a convenience function to point out the rich API offered by getEntityPropery().
     */
    public function getOwnerId () :int
    {
        return int(getEntityProperty(PROP_MEMBER_ID));
    }

    /**
     * @private
     */
    override public function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["receivedChat_v2"] = receivedChat_v2;
    }
}
}
