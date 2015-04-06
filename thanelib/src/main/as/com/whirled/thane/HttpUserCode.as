package com.whirled.thane {

import avmplus.Yard;
import avmplus.Puddle;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

import com.adobe.net.URI;

import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import com.whirled.bureau.client.UserCodeLoader;
import com.whirled.bureau.client.UserCode;

/** Thane implementation of <code>UserCode</code>. */
public class HttpUserCode
    implements UserCode
{
    protected static var log :Log = Log.getLog(HttpUserCode);

    /** Creates a new HttpUserCode and automatically starts downloading code.
     *  @param url the location of the code media (abc file)
     *  @param className the name of the class to look for in the library
     *  @param callback the function to call when the class is found 
     *  @param traceListener the function to call to output messages */
    public function HttpUserCode (
        url :String, className :String, callback :Function, traceListener :Function)
    {
        _url = url;
        _className = className;
        _callback = callback;
        _traceListener = traceListener;

        _yard = _yards.get(url);
        if (_yard != null) {
            setTimeout(yardAvailable, 0);
            return;
        }

        _loader = new URLLoader();
        _loader.addEventListener(IOErrorEvent.IO_ERROR, handleError);
        _loader.addEventListener(Event.COMPLETE, handleComplete);

        _loader.load(new URLRequest(_url));
    }

    /** @inheritDoc */
    // from UserCode
    public function connect (connectListener :Function) :void
    {
        _connectListener = connectListener;
        _bridge.addEventListener("controlConnect", _connectListener);
        _instance = new _class();
        info("New server instantiated: " + _instance);
    }

    /** @inheritDoc */
    // from UserCode
    public function release () :void
    {
        info("Releasing: " + _instance);
        releaseReferences();
    }

    /** @inheritDoc */
    public function outputTrace (str :String, err :Error = null) :void
    {
        Thane.outputToTrace(_puddle, str, err);
    }

    /** @inheritDoc */
    // from Object
    public function toString () :String
    {
        return "HttpUserCode [url=" + _url + ", className=" + _className + ", puddle=" +
            _puddleId + ", class=" + _class + ", instance=" + _instance +
            "]";
    }

    /** Receive some data from teh intarnets. */
    protected function handleError (evt :IOErrorEvent) :void
    {
        log.warning("Error while downloading code", "code", this, "evt", evt);
        _callback(null);
    }

    /** Finished receiving data. */
    protected function handleComplete (evt :Event) :void
    {
        var success :Boolean = false;

        // check again if the yard was resolved while we were waiting
        _yard = _yards.get(_url);
        if (_yard == null) {
            _yard = new Yard(_loader.data);
            _yards.put(_url, _yard);
        }
        yardAvailable();
    }

    protected function yardAvailable () :void
    {
        try {
            _puddleId = "Puddle#" + (++ _lastId);
            _bridge = new EventDispatcher();
            _puddle = Thane.spawnPuddle(_puddleId, _yard, _puddleId + ": ", _bridge);

            _bridge.addEventListener(TraceEvent.TRACE, relayTrace);
            _class = _puddle.domain.getClass(_className);

            info("Successfully spawned " + _puddleId + " with usercode class: " + _class);

        } catch (err :Error) {
            log.error("Error loading user code: " + err.getStackTrace());
            outputTrace("Could not instantiate server class", err);
            informCaller(false);

        } finally {
            _loader = null;
        }

        informCaller(_class != null);
    }

    protected function relayTrace (evt :TraceEvent) :void
    {
        if (evt.trace != null) {
            if (_traceListener == null) {
                trace("Eek, got a trace I couldn't place: " + evt.trace.join(" "));
                return;
            }
            _traceListener(evt.trace.join(" "));
        }
    }

    protected function info (msg :String) :void
    {
        log.info(_puddleId + ": " + msg);
    }

    protected function informCaller (success :Boolean) :void
    {
        try {
            _callback(success ? this : null);

        } catch (err :Error) {
            log.warning("Error invoking callback: " + err.getStackTrace());
            releaseReferences();
        }

        _callback = null;

        if (!success) {
            release();
        }
    }

    /** Set everything we've used to null. */
    protected function releaseReferences () :void
    {
        if (_bridge != null) {
            _bridge.removeEventListener(TraceEvent.TRACE, relayTrace);
            _bridge.removeEventListener("controlConnect", _connectListener);
            _bridge = null;
        }

        _connectListener = null;
        _traceListener = null;

        if (_puddle != null) {
            Thane.unspawnPuddle(_puddleId);
        }
        _puddle = null;
        _yard = null;

        _class = null;
        _instance = null;
    }

    protected var _url :String;
    protected var _puddleId :String;
    protected var _className :String;
    protected var _callback :Function;
    protected var _loader :URLLoader;
    protected var _bridge: EventDispatcher;
    protected var _traceListener :Function;
    protected var _connectListener :Function;
    protected var _yard :Yard;
    protected var _puddle :Puddle;
    protected var _class :Class;
    protected var _instance :Object;

    protected static var _lastId :int;

    // track yards per URL
    protected static var _yards :Map = Maps.newMapOf(String);
}

}
