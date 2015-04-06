//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

/** 
 * Represents user code loaded from an external server. Provided by an implementation of 
 * <code>UserCodeLoader</code>.
 * @see UserCodeLoader
 */
public interface UserCode
{
    /** Connects to the user code, assigning it the given host props and returning the user 
     *  props. */
    function connect (connectListener :Function) :void;

    /** Releases this code. Once released, <code>connect</code> may no longer be used and 
     *  all references to the instance should be cleared. */
    function release () :void;

    /** Outputs a trace using the trace function inside this user code. Optionally also print the
     *  stack trace of an error. */
    function outputTrace (str :String, error :Error = null) :void;
}
}
