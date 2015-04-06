//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * Event.UNLOAD
 * Dispatched when the SWF using this control has been unloaded.
 * You should clean-up any resources that would otherwise stick around, like stopping any
 * Timers, cancelling any sound streams, etc.
 *
 * @eventType flash.events.Event.UNLOAD
 */
[Event(name="unload", type="flash.events.Event")]

[Exclude(name="dispatchEvent", kind="method")]
[Exclude(name="willTrigger", kind="method")]
[Exclude(name="hasEventListener", kind="method")]

/**
 * The abstract base class for all controls and subcontrols.
 */
public class AbstractControl extends EventDispatcher
{
    /**
     * @param disp the display object on the stage
     * @param initialUserProps any userProps that should be configured even prior to setUserProps.
     * @private
     */
    public function AbstractControl (disp :DisplayObject, initialUserProps :Object = null)
    {
        // always create our sub-controls
        _subControls = createSubControls();

        // stop here if we ourselves are a sub-control
        if (this is AbstractSubControl) {
            return;
        }

        if (disp.root == null) {
            throw new Error("Display object used to instantiate a control must be on the stage");
        }

        // set up the unload event to propagate
        disp.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload, false, 0, true);

        // do the connect!
        var userProps :Object = (initialUserProps != null) ? initialUserProps : new Object();
        setUserProps(userProps);
        var event :ConnectEvent = new ConnectEvent();
        event.props.userProps = userProps;
        disp.root.loaderInfo.sharedEvents.dispatchEvent(event);
        if (Boolean(event.props.alreadyConnected)) {
            throw new Error("You've already set up a Control instance. There should only be one.");
        }
        var hostProps :Object = event.props.hostProps;
        if (hostProps != null) {
            gotHostProps(hostProps);
        }
    }

    /**
     * Registers an event listener.
     */
    // inherited from EventDispatcher, but we generate fucked-up asdocs
    override public function addEventListener (
        type :String, listener :Function, useCapture :Boolean = false, priority :int = 0,
        useWeakReference :Boolean = false) :void
    {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    /**
     * Unregisters an event listener.
     */
    // inherited from EventDispatcher, but we generate fucked-up asdocs
    override public function removeEventListener (
        type :String, listener :Function, useCapture :Boolean = false) :void
    {
        super.removeEventListener(type, listener, useCapture);
    }

    /**
     * Are we connected and running inside the whirled environment, or has someone just
     * loaded up our SWF by itself?
     */
    public function isConnected () :Boolean
    {
        return (_funcs != null);
    }

    /**
     * Execute the specified function as a batch of commands that will be sent to the server
     * together.  Messages can be sent no faster than a rate of 10 per second.  Using doBatch groups
     * a number of set or sendMessage operations so that they are treated as a single unit towards
     * this limit. For best performance, it should be used whenever a number of values are being set
     * at once.
     *
     * @example
     * <listing version="3.0">
     * _ctrl.doBatch(function () :void {
     *     _ctrl.net.set("board", new Array(100));
     *     _ctrl.net.set("scores", new Dictionary());
     *     _ctrl.net.set("captures", 0);
     * });
     * </listing>
     *
     * Note that it guarantees that those events get processed by the server as a unit, but
     * the results will not come back as a unit. So, for instance, when you receive the
     * PropertyChangedEvent for "board", checking the value of "scores" will still return
     * the old value.
     *
     * It is NOT an error to call doBatch again from within the function passed to doBatch.
     * All batched messages will be sent when the outermost doBatch function completes.
     */
    public function doBatch (fn :Function, ... args) :void
    {
        callHostCode("startTransaction");
        try {
            fn.apply(null, args);
        } finally {
            callHostCode("commitTransaction");
        }
    }

    /**
     * Handle any shutdown required.
     * @private
     */
    protected function handleUnload (event :Event) :void
    {
        // redispatch the unload event to listeners of this object
        dispatchEvent(event);
    }

    /**
     * Populate any properties or functions we want to expose to the host code.
     * @private
     */
    public function setUserProps (o :Object) :void
    {
        for each (var ctrl :AbstractSubControl in _subControls) {
            ctrl.setUserProps(o);
        }
    }

    /**
     * WHIRLED INTERNAL. Grab any properties needed from our host code.
     * @private
     */
    public function gotHostProps (o :Object) :void
    {
        // by default, we just use these props as our _funcs
        _funcs = o;

        for each (var ctrl :AbstractSubControl in _subControls) {
            ctrl.gotHostProps(o);
        }
    }

    /**
     * WHIRLED INTERNAL. Call a method exposed by the host code.
     * @private
     */
    public function callHostCode (name :String, ... args) :*
    {
        if (_funcs != null) {
            try {
                var func :Function = (_funcs[name] as Function);
                if (func == null) {
                    trace("Host code \"" + name + "\" not found!");
                } else {
                    return func.apply(null, args);
                }
            } catch (err :Error) {
                trace("Error! Your code is broken! Unable to call a host method, perhaps " +
                    "you've been shut down? [msg=" + err.message +
                    ", trace=" + err.getStackTrace() + "].");
            }

        } else {
            checkIsConnected();
        }

        // if we get here then either _funcs is not null, but our function is not there, or
        // _funcs is null but checkIsConnected() thinks everything is ok.
        return undefined;
    }

    /**
     * Helper method to throw an error if we're not connected.
     * @private
     */
    protected function checkIsConnected () :void
    {
        if (!isConnected()) {
            throw new IllegalOperationError(
                "The control is not connected to the host framework, please check isConnected(). " +
                "If false, your SWF is being viewed standalone and should adjust.");
        }
    }

    /**
     * Override and return any custom sub-controls.
     * @private
     */
    protected function createSubControls () :Array
    {
        return null;
    }

    /** The functions supplied by the host. @private */
    protected var _funcs :Object;

    /** Any sub-controls we may have. @private */
    protected var _subControls :Array;
}
}

import flash.events.Event;

/**
 * A special event we can use to pass info back to whirled.
 */
class ConnectEvent extends Event
{
    /** A place to store all properties, rather than make this a dynamic class. */
    public var props :Object;

    /** Construct a new ConnectEvent. */
    public function ConnectEvent (propsObj :Object = null)
    {
        super("controlConnect", true, false);
        props = propsObj || {};
    }

    override public function clone () :Event
    {
        // The cloned object needs to accessing and modifying the same props.
        return new ConnectEvent(props);
    }
}
