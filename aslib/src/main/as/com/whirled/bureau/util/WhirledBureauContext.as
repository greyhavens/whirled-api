//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.util {

import com.threerings.bureau.util.BureauContext;
import com.whirled.bureau.client.UserCodeLoader;

/** Provides access to services for whirled bureau clients. */
public interface WhirledBureauContext extends BureauContext
{
    /**
     * Access the implementation of the user code loader for this client.
     */
    function getUserCodeLoader () :UserCodeLoader;
}

}
