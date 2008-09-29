//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.bureau.client {

import flash.utils.Timer;
import flash.events.TimerEvent;

import com.threerings.io.TypedArray;

import com.threerings.presents.dobj.ObjectAccessError;
import com.threerings.presents.dobj.Subscriber;
import com.threerings.presents.dobj.SubscriberAdapter;

import com.threerings.presents.util.SafeSubscriber;

import com.threerings.bureau.client.Agent;
import com.threerings.bureau.Log;

import com.whirled.bureau.util.WhirledBureauContext;

import com.whirled.bureau.data.GameAgentObject;

import com.whirled.game.client.ThaneGameController;

import com.whirled.game.data.WhirledGameObject;

/** The container for a user's game control code. */
public class GameAgent extends Agent
{
    public function GameAgent (ctx :WhirledBureauContext)
    {
        _ctx = ctx; 

        _traceTimer.addEventListener(TimerEvent.TIMER, handleTimer);
   }

    // from Agent
    public override function start () :void
    {
        Log.info("Starting agent " + _agentObj);

        // subscribe to the game object
        var delegator :Subscriber = 
            new SubscriberAdapter(objectAvailable, requestFailed);

        Log.info("Subscribing to game object " + gameAgentObj.gameOid);

        _subscriber = new SafeSubscriber(gameAgentObj.gameOid, delegator);
        _subscriber.subscribe(_ctx.getDObjectManager());

        // download the code
        _ctx.getUserCodeLoader().load(
            _agentObj.code, 
            _agentObj.className, 
            gotUserCode);
    }

    // from Agent
    public override function stop () :void
    {
        Log.info("Stopping agent " + _agentObj);

        handleTimer(null);
        _traceTimer.stop();
        _traceTimer.removeEventListener(TimerEvent.TIMER, handleTimer);
        _traceTimer = null;

        _subscriber.unsubscribe(_ctx.getDObjectManager());
        _subscriber = null;
        _gameObj = null;
        _agentObj = null;

        if (_controller != null) {
            _controller.shutdown();
            _controller = null;
        }

        if (_userCode != null) {
            _userCode.release();
            _userCode = null;
        }
    }

    /** Access the agent object, casted to a game agent object. */
    protected function get gameAgentObj () :GameAgentObject
    {
        return _agentObj as GameAgentObject;
    }

    /**
     * Callback for when the request to subscribe to the game object finishes and the object is 
     * available.
     */
    protected function objectAvailable (gameObj :WhirledGameObject) :void
    {
        Log.info("Subscribed to game object " + gameObj);
        _gameObj = gameObj;

        _controller = createController();
        _controller.init(_ctx, _gameObj, gameAgentObj.config);

        if (_userCode != null && _gameObj != null) {
            launchUserCode();
        }
    }

    /**
     * Callback for when the a request to subscribe to the game object fails.
     */
    protected function requestFailed (oid :int, cause :ObjectAccessError) :void
    {
        Log.warning("Could not subscribe to game object [oid=" + oid + "]");
        Log.logStackTrace(cause);
        _controller.agentFailed();
    }

    /**
     * Callback for when the user code is available.
     */
    protected function gotUserCode (userCode :UserCode) :void
    {
        if (userCode == null) {
            Log.warning("Unable to load user code [agent: " + _agentObj + "]");
            _controller.agentFailed();
            return;
        }

        _userCode = userCode;
        Log.info("Loaded user code " + _userCode);

        if (_userCode != null && _gameObj != null) {
            launchUserCode();
        }
    }

    /**
     * Called once the game object and the user code (domain) are available.
     */
    protected function launchUserCode () :void
    {
        _userCode.connect(_controller.backend.getConnectListener(), relayTrace);
        
        if (!_controller.backend.isConnected()) {
            Log.info("Could not connect to user code");
            _controller.agentFailed();
            return;
        }

        _controller.agentReady();
    }

    /**
     * Called whenever a trace() is sent back to us from a usercode Domain; we batch these up and
     * relay back to the server periodically and on shutdown.
     */
    protected function relayTrace (trace :String) :void
    {
        _traceOutput.push(trace);
        _traceTimer.start();
    }

    /**
     * Checks to see if we have some trace output to send to the server an if so, sends it.
     */
    protected function handleTimer (event :TimerEvent) :void
    {
        if (_traceOutput.length == 0) {
            _traceTimer.stop();

        } else {
            if (_gameObj != null && _gameObj.manager != null) {
                _gameObj.manager.invoke("agentTrace", _traceOutput);
            }
            _traceOutput.length = 0;
        }
    }

    /**
     * Creates the controller for this agent. 
     */
    protected function createController () :ThaneGameController
    {
        return new ThaneGameController();
    }

    protected var _subscriber :SafeSubscriber;
    protected var _ctx :WhirledBureauContext;
    protected var _gameObj :WhirledGameObject;
    protected var _userCode :UserCode;
    protected var _controller :ThaneGameController;
    protected var _traceOutput :TypedArray = TypedArray.create(String);
    protected var _traceTimer :Timer = new Timer(1000);
}

}
