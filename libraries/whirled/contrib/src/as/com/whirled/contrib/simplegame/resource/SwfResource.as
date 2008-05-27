// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.simplegame.resource {

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

public class SwfResource
    implements Resource
{
    public static function instantiateMovieClip (resourceName :String, className :String) :MovieClip
    {
        var theClass :Class = getClass(resourceName, className);
        return (null != theClass ? new theClass() : null);
    }

    public static function getBitmapData (resourceName :String, className :String, width :int, height :int) :BitmapData
    {
        var theClass :Class = getClass(resourceName, className);
        return (null != theClass ? new theClass(width, height) : null);
    }

    public static function getSwfDisplayRoot (resourceName :String) :DisplayObject
    {
        var swf :SwfResource = get(resourceName);
        return (null != swf ? swf.displayRoot : null);
    }

    public static function get (resourceName :String) :SwfResource
    {
        return ResourceManager.instance.getResource(resourceName) as SwfResource;
    }

    protected static function getClass (resourceName :String, className :String) :Class
    {
        var swf :SwfResource = get(resourceName);
        return (null != swf ? swf.getClass(className) : null);
    }

    public function SwfResource (resourceName :String, loadParams :Object)
    {
        _resourceName = resourceName;
        _loadParams = loadParams;

        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.INIT, onInit);
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
    }

    public function get resourceName () :String
    {
        return _resourceName;
    }

    public function get displayRoot () :DisplayObject
    {
        return _loader.content;
    }

    public function getSymbol (name :String) :Object
    {
        try {
            return _loader.contentLoaderInfo.applicationDomain.getDefinition(name);
        } catch (e :Error) {
            // swallow the exception and return null
        }

        return null;
    }

    public function hasSymbol (name :String) :Boolean
    {
        return _loader.contentLoaderInfo.applicationDomain.hasDefinition(name);
    }

    public function getFunction (name :String) :Function
    {
        return this.getSymbol(name) as Function;
    }

    public function getClass (name :String) :Class
    {
        return this.getSymbol(name) as Class;
    }

    public function load (completeCallback :Function, errorCallback :Function) :void
    {
        _completeCallback = completeCallback;
        _errorCallback = errorCallback;

        // parse loadParams

        var context :LoaderContext = new LoaderContext();
        if (_loadParams.hasOwnProperty("useSubDomain") && !Boolean(_loadParams["useSubDomain"])) {
            context.applicationDomain = ApplicationDomain.currentDomain;
        } else {
            // default to loading symbols into a subdomain
            context.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
        }

        if (_loadParams.hasOwnProperty("url")) {
            _loader.load(new URLRequest(_loadParams["url"]), context);
        } else if (_loadParams.hasOwnProperty("bytes")) {
            _loader.loadBytes(_loadParams["bytes"], context);
        } else if (_loadParams.hasOwnProperty("embeddedClass")) {
            _loader.loadBytes(ByteArray(new _loadParams["embeddedClass"]()), context);
        } else {
            throw new Error("SwfResourceLoader: one of 'url', 'bytes', or 'embeddedClass' must be specified in loadParams");
        }
    }

    public function unload () :void
    {
        try {
            _loader.close();
        } catch (e :Error) {
            // swallow the exception
        }

        _loader.unload();
    }

    protected function onInit (...ignored) :void
    {
        _completeCallback(this);
    }

    protected function onError (e :IOErrorEvent) :void
    {
        _errorCallback(this, "SwfResouceLoader (" + _resourceName + "): " + e.text);
    }

    protected var _resourceName :String;
    protected var _loadParams :Object;
    protected var _loader :Loader;
    protected var _completeCallback :Function;
    protected var _errorCallback :Function;
}

}