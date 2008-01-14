package com.whirled.contrib.core {

import com.threerings.util.Assert;
import com.threerings.util.SortedHashMap;

import com.whirled.contrib.core.tasks.ParallelTask;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.DisplayObjectContainer;

public class AppObject
{
    /**
     * Returns the id that uniquely identifies this object in its containing AppMode.
     */
    public final function get id () :uint
    {
        return _objectId;
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
     * Returns the set of groups that this object belongs to.
     * The groups are returned as an Array of Strings.
     * Objects cannot change their group membership once added to a mode.
     */
    public function get objectGroups () :Array
    {
        return new Array();
    }

    /** Returns true if the object is in the specified group. */
    public function isInGroup (groupName :String) :Boolean
    {
        return this.objectGroups.contains(groupName);
    }

    /** Removes the AppObject from its parent database. */
    public function destroySelf() :void
    {
        _parentDB.destroyObject(_objectId);
    }

    /** Adds an unnamed task to this AppObject. */
    public function addTask (task :ObjectTask) :void
    {
        Assert.isTrue(null != task);
        _anonymousTasks.addTask(task);
    }

    /** Adds a named task to this AppObject. */
    public function addNamedTask (name :String, task :ObjectTask) :void
    {
        Assert.isTrue(null != task);
        Assert.isTrue(null != name);
        Assert.isTrue(name.length > 0);

        var namedTaskContainer :ParallelTask = (_namedTasks.get(name) as ParallelTask);
        if (null == namedTaskContainer) {
            namedTaskContainer = new ParallelTask();
            _namedTasks.put(name, namedTaskContainer);
        }

        namedTaskContainer.addTask(task);
    }

    /** Removes all tasks from the AppObject. */
    public function removeAllTasks () :void
    {
        _anonymousTasks.removeAllTasks();
        _namedTasks.clear();
    }

    /** Removes all tasks with the given name from the AppObject. */
    public function removeNamedTasks (name :String) :void
    {
        Assert.isTrue(null != name);
        Assert.isTrue(name.length > 0);

        _namedTasks.remove(name);
    }

    /** Returns true if the AppObject has any tasks. */
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

    /** Returns true if the AppObject has any tasks with the given name. */
    public function hasTasksNamed (name :String) :Boolean
    {
        var namedTaskContainer :ParallelTask = (_namedTasks.get(name) as ParallelTask);
        return (null == namedTaskContainer ? false : namedTaskContainer.hasTasks());
    }

    /** Called once per update tick. (Subclasses can override this to do something useful.) */
    protected function update (dt :Number) :void
    {
    }

    /**
     * Called immediately after the AppObject has been added to an ObjectDB.
     * (Subclasses can override this to do something useful.)
     */
    protected function addedToDB (db :ObjectDB) :void
    {
    }

    /**
     * Called immediately after the AppObject has been removed from an AppMode.
     * (Subclasses can override this to do something useful.)
     */
    protected function removedFromDB (db :ObjectDB) :void
    {
    }

    /**
     * Called to deliver a message to the object.
     * (Subclasses can override this to do something useful.)
     */
    protected function receiveMessage (msg :ObjectMessage) :void
    {

    }

    internal function addedToDBInternal (db :ObjectDB) :void
    {
        addedToDB(db);
    }

    internal function removedFromDBInternal (db :ObjectDB) :void
    {
        removedFromDB(db);
    }

    internal function updateInternal (dt :Number) :void
    {
        _anonymousTasks.update(dt, this);

        var thisAppObject :AppObject = this;
        _namedTasks.forEach(updateNamedTaskContainer);

        update(dt);

        function updateNamedTaskContainer (name :*, tasks :*) :void {
            // Tasks may be removed from the object during the _namedTasks.forEach() loop.
            // When this happens, we'll get undefined 'tasks' objects.
            if (undefined !== tasks) {
                (tasks as ParallelTask).update(dt, thisAppObject);
            }
        }
    }

    internal function receiveMessageInternal (msg :ObjectMessage) :void
    {
        _anonymousTasks.receiveMessage(msg);

        _namedTasks.forEach(
            function (name :*, tasks:*) :void {
                if (undefined !== tasks) {
                    (tasks as ParallelTask).receiveMessage(msg);
                }
            });

        receiveMessage(msg);
    }

    protected var _anonymousTasks :ParallelTask = new ParallelTask();

    // stores a mapping from String to ParallelTask
    protected var _namedTasks :SortedHashMap = new SortedHashMap(SortedHashMap.STRING_KEYS);

    // managed by AppMode
    internal var _objectId :uint;
    internal var _parentDB :ObjectDB;
}

}