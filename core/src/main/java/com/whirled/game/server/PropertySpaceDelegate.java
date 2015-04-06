package com.whirled.game.server;

import java.util.Map;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.parlor.server.PlayManager;
import com.threerings.parlor.server.PlayManagerDelegate;

import com.whirled.game.data.PropertySpaceObject;

import static com.whirled.Log.log;

/**
 * A delegate that initializes its {@link PlayManager}'s {@link PlaceObject} (which should
 * implement {@link PropertySpaceObject}) with properties from persistent storage. The data
 * must have already been read from the database by the time the manager starts up.
 */
public abstract class PropertySpaceDelegate extends PlayManagerDelegate
{
    protected abstract Map<String, byte[]> initialStateFromStore ();
    protected abstract void writeDirtyStateToStore (Map<String, byte[]> dirtyProps);

    @Override
    public void didStartup (PlaceObject plobj)
    {
        super.didStartup(plobj);
        if (plobj instanceof PropertySpaceObject) {
            _psObj = (PropertySpaceObject) plobj;

            PropertySpaceHelper.initWithProperties(
                _psObj, PropertySpaceHelper.recordsToProperties(initialStateFromStore()), false);

        } else {
            log.warning("This delegate needs a PropertySpaceObject to work on");
        }
    }

    @Override
    public void didShutdown ()
    {
        super.didShutdown();

        if (_psObj != null) {
            writeDirtyStateToStore(PropertySpaceHelper.encodeDirtyStateForStore(_psObj));
        }
    }

    protected PropertySpaceObject _psObj;
}
