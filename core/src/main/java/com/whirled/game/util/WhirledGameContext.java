//
// $Id$

package com.whirled.game.util;

import com.threerings.util.MessageManager;

import com.threerings.parlor.util.ParlorContext;

/**
 * Extends the Parlor context with bits needed by the whirled game framework.
 */
public interface WhirledGameContext extends ParlorContext
{
    /** Returns a message manager that can be used to translate strings. */
    public MessageManager getMessageManager ();
}
