//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

/** Interface to allow agents to load and unload the code that they're running. */
public interface UserCodeLoader
{
    /** 
     * Load the code media (abc file) from the given url, find the given class name inside it and 
     * invoke the callback when the code is ready. The callback must take a single argument of type 
     * <code>UserCode</code>:
     * 
     * <p><code>
     * function callback (code :UserCode) :void
     * </code></p>
     *
     * <p>If the media could not be loaded or the class could not be found, the callback will be 
     * invoked with null.</p>
     * 
     * <p>Each uccessful call to <code>load</code> must be paired with a corresponding 
     * <code>UserCode.release()</code> call.</p>
     *
     * The given <code>traceFn</code> takes a single string argument and is called with any
     * messages output directly by the code or by the loading process.
     *
     * @see UserCode
     */
    function load (url :String, name :String, traceFn :Function, callback :Function) :void;
}

}
