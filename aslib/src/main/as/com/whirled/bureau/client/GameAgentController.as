//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

/**
 * Defines basic methods a game agent controller must provide.
 */
public interface GameAgentController
{
    /**
     * Tells the controller that the agent is stopped.
     */
    function shutdown () :void;

    /**
     * Notifies the server that the agent could not be started (e.g. the code could not be loaded or
     * the user code threw an exception).
     */
    function agentFailed () :void;

    /**
     * Gets the function that will be called with the connect event from the user code (when the
     * user code constructs its top-level <code>AbstactControl</code> object).
     */
    function getConnectListener () :Function;

    /**
     * Tests if the front end code has performed a connect.
     */
    function isConnected () :Boolean;

    /**
     * Notifies the server that all the code is loaded and the agent is ready to start receiving
     * players and other data.
     */
    function agentReady () :void;
}
}
