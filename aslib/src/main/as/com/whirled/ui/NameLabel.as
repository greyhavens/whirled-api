//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.ui {

import mx.core.IUIComponent;

/**
 * An interface to enforce that the rendering class of PlayerList members allows some status 
 * indication.  Implicit in the extension of IUIComponent is that the concrete implementation 
 * extends DisplayObject and can be added to the display list (also, clearly, as a Flex component).
 */
public interface NameLabel extends IUIComponent
{
    /**
     * Status to indicate in the rendering of this NameLabel.  Base status constants are indicated
     * in <code>PlayerList</code>
     * @see PlayerList
     */
    function setStatus (status :String) :void
}
}
