//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.errors.IllegalOperationError;

import mx.core.ClassFactory;
import mx.core.ScrollPolicy;

import mx.collections.ArrayCollection;
import mx.collections.Sort;

import mx.controls.Label;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.Name;

import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.ElementUpdateListener;
import com.threerings.presents.dobj.ElementUpdatedEvent;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.SetListener;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.parlor.game.data.GameObject;
import com.threerings.parlor.game.data.UserIdentifier;

import com.threerings.parlor.turn.data.TurnGameObject;

import com.whirled.ui.PlayerList;
import com.whirled.ui.NameLabelCreator;

/**
 * A standard flex players list for use in games.
 */
public class GamePlayerList extends PlayerList
    implements AttributeChangeListener, ElementUpdateListener, SetListener
{
    public function GamePlayerList (labelCreator :NameLabelCreator = null)
    {
        super(labelCreator);
    }

    /**
     * Start up this player list.
     */
    public function startup (plobj :PlaceObject) :void
    {
        _gameObj = plobj as GameObject;
        _gameObj.addListener(this);

        var record :GamePlayerRecord;

        // find all the current occupants and add them to the set
        for each (var occInfo :OccupantInfo in _gameObj.occupantInfo.toArray()) {
            record = createNewRecord();
            record.setup(occInfo);

            _byName.put(occInfo.username, record);
            _byId.put(UserIdentifier.getUserId(occInfo.username), record);
            addItem(record);
        }

        // add all the players specified in the players array, if any
        for each (var name :Name in _gameObj.players) {
            record = _byName.get(name) as GamePlayerRecord;
            var newRecord :Boolean = (record == null);
            if (newRecord) {
                record = createNewRecord();
                record.setupAbsent(name);
            }

            record.isPlayer = true;

            if (newRecord) {
                _byName.put(name, record);
                addItem(record);
            }
        }

        _players.refresh();

        // set the current turn-holder, if applicable
        if (_gameObj is TurnGameObject) {
            record = _byName.get((_gameObj as TurnGameObject).getTurnHolder());
            _list.selectedItem = _values.get(record);
        }
    }

    /**
     * Shut down this player list.
     */
    public function shutdown () :void
    {
        _gameObj.removeListener(this);
        _gameObj = null;

        _byId.clear();
        _byName.clear();
        _players.removeAll();
    }

    /**
     * Label the players list with a string.
     */
    public function setLabel (label :String) :void
    {
        if (label == null) {
            if (_label != null) {
                removeChild(_label);
                _label = null;
            }

        } else {
            if (_label == null) {
                _label = new Label();
                _label.setStyle("textAlign", "center");
                _label.percentWidth = 100;
                addChildAt(_label, 0);
            }
            _label.text = label;
        }
    }

    /**
     * Clear out the score data for all records.
     */
    public function clearScores (clearValue :Object = null, sortValuesToo :Boolean = false) :void
    {
        for (var ii :int = _players.length - 1; ii >= 0; ii--) {
            var entry :Array = _players.getItemAt(ii) as Array;
            if (entry == null) {
                log.warning("null entry in _players [ii=" + ii + "]");
                continue;
            }

            var record :GamePlayerRecord = entry[1] as GamePlayerRecord;
            if (record == null) {
                log.warning("data field in _players not a GamePlayerRecord [ii=" + ii + ", data" + 
                            entry[1] + "]");
                continue;
            }

            record.scoreData = clearValue;
            if (sortValuesToo) {
                record.sortData = null;
            }
        }
        _players.refresh();
    }

    /**
     * Set the scores for players from an array. You may specify either the scores or
     * the sortValues or both.
     */
    public function setPlayerScores (scores :Array, sortValues :Array = null) :void
    {
        var names :Array = _gameObj.players;

        if (scores != null && scores.length != names.length) {
            throw new IllegalOperationError("The length of the scores array does not match " +
                "the length of the players array.");
        }
        if (sortValues != null && sortValues.length != names.length) {
            throw new IllegalOperationError("The length of the sortValues array does not match " +
                "the length of the players array.");
        }

        for (var ii :int = 0; ii < names.length; ii++) {
            var record :GamePlayerRecord = _byName.get(names[ii]) as GamePlayerRecord;
            if (scores != null) {
                record.scoreData = scores[ii];
            }
            if (sortValues != null) {
                record.sortData = sortValues[ii];
            }
        }
        _players.refresh();
    }

    /**
     * Set the scores for any occupants. The keys are the occupantId (oid), the value is
     * used for the score, or if an array, the first value is the score the 2nd is the sortData.
     */
    public function setMappedScores (scores :Object) :void
    {
        for (var playerId :Object in scores) {
            var record :GamePlayerRecord = _byId.get(int(playerId));
            if (record != null) {
                var data :Object = scores[playerId];
                if (data is Array) {
                    var arr :Array = data as Array;
                    record.scoreData = arr[0];
                    record.sortData = arr[1];
                } else {
                    record.scoreData = data;
                }
            }
        }
        _players.refresh();
    }

    // from AttributeChangeListener
    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        // update the displayed turn holder
        if ((_gameObj is TurnGameObject) &&
                (event.getName() == (_gameObj as TurnGameObject).getTurnHolderFieldName())) {
            var record :GamePlayerRecord = _byName.get(event.getValue()) as GamePlayerRecord;
            _list.selectedItem = _values.get(record);
        }
    }

    // from ElementUpdateListener
    public function elementUpdated (event :ElementUpdatedEvent) :void
    {
        // TODO: changes to players array...?
    }

    // from SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            var occInfo :OccupantInfo = (event.getEntry() as OccupantInfo);
            // if the occupant is a player, they may already have a record
            var record :GamePlayerRecord = _byName.get(occInfo.username) as GamePlayerRecord;
            var newRecord :Boolean = (record == null);
            if (newRecord) {
                record = createNewRecord();
            }
            record.setup(occInfo);

            _byId.put(UserIdentifier.getUserId(occInfo.username), record);
            if (newRecord) {
                _byName.put(occInfo.username, record);
                addItem(record);

            } else {
                itemUpdated(record);
            }
        }
    }

    // from SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            // I guess we might be updating the name or the headshot
            var occInfo :OccupantInfo = (event.getEntry() as OccupantInfo);
            var record :GamePlayerRecord = _byName.get(occInfo.username) as GamePlayerRecord;
            record.setup(occInfo);
            itemUpdated(record);
        }
    }

    // from SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            var occInfo :OccupantInfo = (event.getOldEntry() as OccupantInfo);
            var record :GamePlayerRecord =
                _byId.remove(UserIdentifier.getUserId(occInfo.username)) as GamePlayerRecord;

            // if this is a player, strip the id but leave it in the lists
            if (ArrayUtil.contains(_gameObj.players, occInfo.username)) {
                record.setup(null);
                itemUpdated(record);

            } else {
                // otherwise, remove it completely
                _byName.remove(occInfo.username);
                removeItem(record);
            }
        }
    }

    // we have our own implementation of PlayerRenderer
    override protected function getRenderingClass () :Class
    {
        return GamePlayerRenderer;
    }

    protected function createNewRecord () :GamePlayerRecord
    {
        return new GamePlayerRecord();
    }

    private static const log :Log = Log.getLog(GamePlayerList);

    /** The game object. */
    protected var _gameObj :GameObject;

    /** An optional label for the list of players. */
    protected var _label :Label;

    /** A mapping of id -> record */
    protected var _byId :Map = Maps.newMapOf(int);

    /** A mapping of name -> record. */
    protected var _byName :Map = Maps.newMapOf(Name);
}
}
