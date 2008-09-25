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

package com.whirled.contrib {

import flash.events.IEventDispatcher;

/**
 * A class for keeping track of event listeners and freeing them all at a given time.  This is
 * useful for keeping track of your ENTER_FRAME listeners, and releasing them all on UNLOAD to
 * make sure your game/furni/avatar fully unloads at the proper time.
 *
 * See {@link EventHandlerManager} for a non-static version of this class.
 */
public class EventHandlers
{
    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     */
    public static function registerEventListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false, priority :int = 0,
        useWeakReference :Boolean = false) :void
    {
        _mgr.registerEventListener(dispatcher, event, listener, useCapture, priority,
            useWeakReference);
    }

    /**
     * Removes the specified listener from the specified dispatcher for the specified event.
     */
    public static function unregisterEventListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false) :void
    {
        _mgr.unregisterEventListener(dispatcher, event, listener, useCapture);
    }

    /**
     * Registers a zero-arg callback function that should be called once when the event fires.
     */
    public static function registerOneShotCallback (dispatcher :IEventDispatcher, event :String,
        callback :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _mgr.registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
    }

    /**
     * Registers the freeAllHandlers() method to be called upon Event.UNLOAD on the supplied
     * event dispatcher.
     */
    public static function registerUnload (dispatcher :IEventDispatcher) :void
    {
        _mgr.registerUnload(dispatcher);
    }

    /**
     * Free all handlers that have been added via this registerEventListener() and have not been
     * freed already via unregisterEventListener()
     */
    public static function freeAllHandlers (...ignored) :void
    {
        _mgr.freeAllHandlers();
    }

    protected static var _mgr :EventHandlerManager = new EventHandlerManager();
}
}