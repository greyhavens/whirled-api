//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

import com.threerings.util.Log;

import com.threerings.bureau.client.BureauClient;
import com.threerings.bureau.client.BureauDirector;
import com.threerings.bureau.util.BureauContext;
import com.threerings.presents.client.ClientEvent;
import com.whirled.bureau.util.WhirledBureauContext;

/** The bureau client for whirled. */
public class WhirledBureauClient extends BureauClient
{
    public static var log :Log = Log.getLog(WhirledBureauClient);

    /**
     * Launches a new client from command line (String) arguments. 
     * @param argv array of command line arguments: (bureauId) (token) (port) (logLevel)
     * @param version for authenticaion, the deployment version
     * @param userCodeLoader the implementation to use to download user code
     * @param cleanup the function to call when the client is no longer in use:
     * <pre>
     *     function cleanup (client :WhirledBureauClient) :void
     * </pre>
     */
    public static function main (
        args :Array, version :String, userCodeLoader :UserCodeLoader, cleanup :Function) :void
    {
        var bureauId :String = args[0];
        var token :String = args[1];
        var server :String = "localhost";
        var port :int = parseInt(args[2]);
        var logLevel :String = args[3] as String;

        Log.setLevels(":" + logLevel);

        log.info(
            "Starting client with token=" + token + 
            ", bureauId=" + bureauId + 
            ", server=" + server + 
            ", port=" + port +
            ", logLevel=" + logLevel);

        // create the client and log on
        var client :WhirledBureauClient = new WhirledBureauClient(
            token, bureauId, userCodeLoader, cleanup);
        client.setVersion(version);
        client.setServer(server, [port]);
        client.logon();
    }

    /**
     * Creates a new client. 
     * @param token the authentication token assigned by the server to this bureau
     * @param bureauId the bureau id assigned by the server to this bureau
     * @param userCodeLoader the implementation to use to download user code
     * @param cleanup the function to call when the client is no longer accessible:
     * <pre>
     *     function cleanup (client :WhirledBureauClient) :void
     * </pre>
     */
    public function WhirledBureauClient (
        token :String, bureauId :String, userCodeLoader :UserCodeLoader, cleanup :Function = null)
    {
        super(token, bureauId);
        _userCodeLoader = userCodeLoader;
        if (cleanup == null) {
            cleanup = function (...args) :void {};
        }
        _cleanup = cleanup;
        addEventListener(ClientEvent.CLIENT_DID_LOGOFF, clientDidLogoff);
        addEventListener(ClientEvent.CLIENT_FAILED_TO_LOGON, clientFailedToLogon);
    }

    public function getUserCodeLoader () :UserCodeLoader
    {
        return _userCodeLoader;
    }

    // from BureauClient
    protected override function createDirector () :BureauDirector
    {
        return new WhirledBureauDirector(_ctx as WhirledBureauContext);
    }

    // from BureauClient
    protected override function createContext () :BureauContext
    {
        return new ContextImpl(this);
    }

    protected function clientDidLogoff (evt :ClientEvent) :void
    {
        log.info("Client logged off, cleaning up", "evt", evt);
        _cleanup(this);
    }

    protected function clientFailedToLogon (evt :ClientEvent) :void
    {
        log.info("Client failed to logon, cleaning up", "evt", evt);
        _cleanup(this);
    }

    protected var _userCodeLoader :UserCodeLoader;
    protected var _cleanup :Function;
}

}

import com.threerings.bureau.client.BureauDirector;
import com.whirled.bureau.client.WhirledBureauClient;
import com.whirled.bureau.util.WhirledBureauContext;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.client.Client;
import com.whirled.bureau.client.UserCodeLoader;

class ContextImpl
    implements WhirledBureauContext
{
    function ContextImpl (client :WhirledBureauClient)
    {
        _client = client;
    }

    public function getBureauDirector () :BureauDirector
    {
        return _client.getBureauDirector();
    }

    public function getDObjectManager () :DObjectManager
    {
        return _client.getDObjectManager();
    }

    public function getClient () :Client
    {
        return _client;
    }

    public function getBureauId () :String
    {
        return _client.getBureauId();
    }

    public function getUserCodeLoader () :UserCodeLoader
    {
        return _client.getUserCodeLoader();
    }

    protected var _client :WhirledBureauClient;
}
