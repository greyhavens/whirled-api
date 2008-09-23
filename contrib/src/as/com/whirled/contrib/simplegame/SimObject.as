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

package com.whirled.contrib.simplegame {

import com.threerings.util.SortedHashMap;
import com.whirled.contrib.simplegame.tasks.ParallelTask;
import com.whirled.contrib.simplegame.tasks.TaskContainer;

import flash.events.EventDispatcher;

public class SimObject extends EventDispatcher
{
    /**
     * Returns the unique SimObjectRef that stores a reference to this SimObject.
     */
    public final function get ref () :SimObjectRef
    {
        return _ref;
    }

    /**
     * Returns the ObjectDB that this object is contained in.
     */
    public final function get db () :ObjectDB
    {
        return _parentDB;
    }

    /**
     * Returns true if the object is in an ObjectDB and is "live"
     * (not pending removal from the database)
     */
    public function get isLiveObject () :Boolean
    {
        return (null != _ref && !_ref.isNull);
    }

    /**
     * Returns the name of this object.
     * Two objects in the same mode cannot have the same name.
     * Objects cannot change their names once added to a mode.
     */
    public function get objectName () :String
    {
        return null;
    }

    /**
     * Iterates over the groups that this object is a member of.
     * If a subclass overrides this function, it should do something
     * along the lines of:
     *
     * override public function getObjectGroup (groupNum :int) :String
     * {
     *     switch (groupNum) {
     *     case 0: return "Group0";
     *     case 1: return "Group1";
     *     default: return super.getObjectGroup(groupNum - 2); // 2 is the number of groups this class defines
     *     }
     * }
     */
    public function getObjectGroup (groupNum :int) :String
    {
        return null;
    }

    /** Removes the SimObject from its parent database. */
    public function destroySelf () :void
    {
        _parentDB.destroyObject(_ref);
    }

    /** Adds an unnamed task to this SimObject. */
    public function addTask (task :ObjectTask) :void
    {
        if (null == task) {
            throw new ArgumentError("task must be non-null");
        }

        _anonymousTasks.addTask(task);
    }

    /** Adds a named task to this SimObject. */
    public function addNamedTask (name :String, task :ObjectTask, removeExistingTasks :Boolean = false) :void
    {
        if (null == task) {
            throw new ArgumentError("task must be non-null");
        }

        if (null == name || name.length == 0) {
            throw new ArgumentError("name must be at least 1 character long");
        }

        var namedTaskContainer :ParallelTask = (_namedTasks.get(name) as ParallelTask);
        if (null == namedTaskContainer) {
            namedTaskContainer = new ParallelTask();
            _namedTasks.put(name, namedTaskContainer);
        } else if (removeExistingTasks) {
            namedTaskContainer.removeAllTasks();
        }

        namedTaskContainer.addTask(task);
    }

    /** Removes all tasks from the SimObject. */
    public function removeAllTasks () :void
    {
        if (_updatingTasks) {
            // if we're updating tasks, invalidate all named task containers so that
            // they stop iterating their children
            for each (var taskContainer :TaskContainer in _namedTasks.values()) {
                taskContainer.removeAllTasks();
            }
        }

        _anonymousTasks.removeAllTasks();
        _namedTasks.clear();
    }

    /** Removes all tasks with the given name from the SimObject. */
    public function removeNamedTasks (name :String) :void
    {
        if (null == name || name.length == 0) {
            throw new ArgumentError("name must be at least 1 character long");
        }

        var taskContainer :TaskContainer = _namedTasks.remove(name);

        // if we're updating tasks, invalidate this task container so that
        // it stops iterating its children
        if (null != taskContainer && _updatingTasks) {
            taskContainer.removeAllTasks();
        }
    }

    /** Returns true if the SimObject has any tasks. */
    public function hasTasks () :Boolean
    {
        if (_anonymousTasks.hasTasks()) {
            return true;
        } else {
            for each (var namedTaskContainer :* in _namedTasks) {
                if ((namedTaskContainer as ParallelTask).hasTasks()) {
                    return true;
                }
            }
        }

        return false;
    }

    /** Returns true if the SimObject has any tasks with the given name. */
    public function hasTasksNamed (name :String) :Boolean
    {
        var namedTaskContainer :ParallelTask = (_namedTasks.get(name) as ParallelTask);
        return (null == namedTaskContainer ? false : namedTaskContainer.hasTasks());
    }

    /**
     * Called once per update tick. (Subclasses can override this to do something useful.)
     *
     * @param dt the number of seconds that have elapsed since the last update.
     */
    protected function update (dt :Number) :void
    {
    }

    /**
     * Called immediately after the SimObject has been added to an ObjectDB.
     * (Subclasses can override this to do something useful.)
     */
    protected function addedToDB () :void
    {
    }

    /**
     * Called immediately after the SimObject has been removed from an AppMode.
     *
     * removedFromDB is not called when the SimObject's AppMode is removed from the mode stack.
     * For logic that must be run in this instance, see {@link #destroyed}.
     *
     * (Subclasses can override this to do something useful.)
     */
    protected function removedFromDB () :void
    {
    }

    /**
     * Called after the SimObject has been removed from the active AppMode, or if the
     * object's containing AppMode is removed from the mode stack.
     *
     * If the SimObject is removed from the active AppMode, {@link #removedFromDB}
     * will be called before destroyed.
     *
     * destroyed should be used for logic that must be always be run when the SimObject is
     * destroyed (disconnecting event listeners, releasing resources, etc).
     *
     * (Subclasses can override this to do something useful.)
     */
    protected function destroyed () :void
    {
    }

    /**
     * Called to deliver a message to the object.
     * (Subclasses can override this to do something useful.)
     */
    protected function receiveMessage (msg :ObjectMessage) :void
    {

    }

    internal function addedToDBInternal () :void
    {
        addedToDB();
    }

    internal function removedFromDBInternal () :void
    {
        removedFromDB();
    }

    internal function destroyedInternal () :void
    {
        destroyed();
    }

    internal function updateInternal (dt :Number) :void
    {
        _updatingTasks = true;
        _anonymousTasks.update(dt, this);
        if (!_namedTasks.isEmpty()) {
            var thisSimObject :SimObject = this;
            _namedTasks.forEach(updateNamedTaskContainer);
        }
        _updatingTasks = false;

        update(dt);

        function updateNamedTaskContainer (name :*, tasks :*) :void {
            // Tasks may be removed from the object during the _namedTasks.forEach() loop.
            // When this happens, we'll get undefined 'tasks' objects.
            if (undefined !== tasks) {
                (tasks as ParallelTask).update(dt, thisSimObject);
            }
        }
    }

    internal function receiveMessageInternal (msg :ObjectMessage) :void
    {
        _anonymousTasks.receiveMessage(msg);

        if (!_namedTasks.isEmpty()) {
            _namedTasks.forEach(
                function (name :*, tasks:*) :void {
                    if (undefined !== tasks) {
                        (tasks as ParallelTask).receiveMessage(msg);
                    }
                });
        }

        receiveMessage(msg);
    }

    protected var _anonymousTasks :ParallelTask = new ParallelTask();

    // stores a mapping from String to ParallelTask
    protected var _namedTasks :SortedHashMap = new SortedHashMap(SortedHashMap.STRING_KEYS);

    protected var _updatingTasks :Boolean;

    // managed by ObjectDB
    internal var _ref :SimObjectRef;
    internal var _parentDB :ObjectDB;
}

}
