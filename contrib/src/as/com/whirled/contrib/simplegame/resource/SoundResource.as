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

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.media.Sound;
import flash.net.URLRequest;

public class SoundResource
    implements Resource
{
    public static const TYPE_SFX :int = 0;
    public static const TYPE_MUSIC :int = 1;
    public static const TYPE__LIMIT :int = 2;

    public function SoundResource (resourceName :String, loadParams :Object)
    {
        _resourceName = resourceName;
        _loadParams = loadParams;
    }

    public function get resourceName () :String
    {
        return _resourceName;
    }

    public function get sound () :Sound
    {
        return _sound;
    }

    public function get type () :int
    {
        return _type;
    }

    public function get priority () :int
    {
        return _priority;
    }

    public function get volume () :Number
    {
        return _volume;
    }

    public function get pan () :Number
    {
        return _pan;
    }

    public function load (completeCallback :Function, errorCallback :Function) :void
    {
        _completeCallback = completeCallback;
        _errorCallback = errorCallback;

        // parse loadParams
        _type = (_loadParams.hasOwnProperty("type") && _loadParams["type"] == "music" ?
            TYPE_MUSIC :
            TYPE_SFX);

        _priority = (_loadParams.hasOwnProperty("priority") ? int(_loadParams["priority"]) : 0);
        _volume = (_loadParams.hasOwnProperty("volume") ? Number(_loadParams["volume"]) : 1);
        _pan = (_loadParams.hasOwnProperty("pan") ? Number(_loadParams["pan"]) : 0);

        if (_loadParams.hasOwnProperty("url")) {
            var completeImmediately :Boolean = (_loadParams.hasOwnProperty("completeImmediately") ?
                Boolean(_loadParams["completeImmediately"]) :
                false);
            var url :String = _loadParams["url"];

            // If the sound is to complete immediately, we don't wait for it to finish loading
            // before we make it available. Sounds loaded in this manner can be played without
            // issue as long as they download quickly enough.
            if (completeImmediately) {
                _sound = new Sound(new URLRequest(url));
                this.onInit();
            } else {
                _sound = new Sound(new URLRequest(_loadParams["url"]));
                _sound.addEventListener(Event.COMPLETE, onInit);
                _sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            }

        } else if (_loadParams.hasOwnProperty("embeddedClass")) {
            try {
                _sound = Sound(new _loadParams["embeddedClass"]());
            } catch (e :Error) {
                this.onError(e.message);
                return;
            }
            this.onInit();
        } else {
            throw new Error("SoundResourceLoader: either 'url' or 'embeddedClass' must be specified in loadParams");
        }
    }

    public function unload () :void
    {
        try {
            if (null != _sound) {
                _sound.close();
            }
        } catch (e :Error) {
            // swallow the exception
        }
    }

    protected function onInit (...ignored) :void
    {
        _completeCallback(this);
    }

    protected function onIOError (e :IOErrorEvent) :void
    {
        this.onError(e.text);
    }

    protected function onError (errString :String) :void
    {
        _errorCallback(this, "SoundResourceLoader (" + _resourceName + "): " + errString);
    }

    protected var _resourceName :String;
    protected var _loadParams :Object;
    protected var _sound :Sound;
    protected var _type :int;
    protected var _priority :int;
    protected var _volume :Number;
    protected var _pan :Number;

    protected var _completeCallback :Function;
    protected var _errorCallback :Function;
}

}