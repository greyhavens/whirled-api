//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.SetListener;

import com.whirled.game.GameContentEvent;
import com.whirled.game.data.GameContentOwnership;
import com.whirled.game.data.GameData;
import com.whirled.game.data.WhirledPlayerObject;

/**
 * Listens for game content related events on a player object and reports appropriate events to the
 * backend.
 */
public class ContentListener implements SetListener
{
    public function ContentListener (playerId :int, gameId :int, target :Object)
    {
        _playerId = playerId;
        _gameId = gameId;
        _target = target;
    }

    // from interface SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        if (event.getName() != WhirledPlayerObject.GAME_CONTENT) {
            return;
        }

        var content :GameContentOwnership = (event.getEntry() as GameContentOwnership);
        if (content.gameId == _gameId &&
            // we only want to notify on the addition of item and level pack data
            (content.type == GameData.LEVEL_DATA || content.type == GameData.ITEM_DATA)) {
            notifyGameContentAdded(content.type, content.ident, _playerId);
        }
    }

    // from interface SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        if (event.getName() != WhirledPlayerObject.GAME_CONTENT) {
            return;
        }
        var content :GameContentOwnership = (event.getEntry() as GameContentOwnership);
        var ocontent :GameContentOwnership = (event.getOldEntry() as GameContentOwnership);
        if (content.gameId == _gameId && content.type == GameData.ITEM_DATA &&
            content.count < ocontent.count) {
            notifyGameContentConsumed(content.type, content.ident, _playerId);
        }
    }

    // from interface SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        if (event.getName() != WhirledPlayerObject.GAME_CONTENT) {
            return;
        }
        var content :GameContentOwnership = (event.getOldEntry() as GameContentOwnership);
        if (content.gameId == _gameId && content.type == GameData.ITEM_DATA) {
            notifyGameContentConsumed(content.type, content.ident, _playerId);
        }
    }

    protected function notifyGameContentAdded (type :int, ident :String, playerId :int) :void
    {
        _target.callUserCode("notifyGameContentAdded_v1", toContentType(type), ident, playerId);
    }

    protected function notifyGameContentConsumed (type :int, ident :String, playerId :int) :void
    {
        _target.callUserCode("notifyGameContentConsumed_v1", toContentType(type), ident, playerId);
    }

    /**
     * Helper function for notifyGameContentAdded and notifyGameContentConsumed.
     */
    protected static function toContentType (type :int) :String
    {
        switch (type) {
        case GameData.ITEM_DATA:
            return GameContentEvent.ITEM_PACK;
        case GameData.LEVEL_DATA:
            return GameContentEvent.LEVEL_PACK;
        default:
            throw new Error("Unknown game content type [type=" + type + "].");
        }
    }

    protected var _playerId :int;
    protected var _gameId :int;
    protected var _target :Object;
}
}
