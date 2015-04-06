//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.display.DisplayObject;

import com.threerings.crowd.util.CrowdContext;
import com.threerings.util.MessageBundle;

import com.whirled.game.data.WhirledGameObject;

/**
 * Extends the standard backend with some useful bits for debugging a user game.
 */
public class TestGameBackend extends WhirledGameBackend
{
    public function TestGameBackend (
        ctx :CrowdContext, gameObj :WhirledGameObject, ctrl :TestGameController)
    {
        super(ctx, gameObj, ctrl);
    }

    // from WhirledGameBackend
    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        o["game_getPartyIds_v1"] = game_getPartyIds_v1;
        o["player_getPartyId_v1"] = player_getPartyId_v1;
        // the rest of the party-related methods are OK as missing, since we never return a partyIds
    }

    // from BaseGameBackend
    override protected function reportGameError (msg :String, err :Error = null) :void
    {
        super.reportGameError(msg, err);

        // in the text environment we also report the stack trace to the chat
        if (err != null) {
            (_ctx as CrowdContext).getChatDirector().displayAttention(
                null, MessageBundle.taint(err.getStackTrace()));
        }
    }

    // from WhirledGameBackend
    override protected function getHeadShot_v2 (occupant :int) :DisplayObject
    {
        validateConnected();

        // return one of two dummy headshots, for testing purposes
        var isFirstOccupant :Boolean = _gameObj.occupants.size() > 0 &&
                                       _gameObj.occupants.get(0) == occupant;
        var shot :DisplayObject = isFirstOccupant ? new HEADSHOT_1() : new HEADSHOT_2();
        shot.x = (Thumbnail.WIDTH - shot.width) / 2;
        shot.y = (Thumbnail.HEIGHT - shot.height) / 2;
        return new Thumbnail(shot);
    }

    // from WhirledGameBackend
    override protected function requestConsumeItemPack_v1 (ident :String, msg :String) :Boolean
    {
        return false; // TODO: to test things properly we really need to get the server involved
    }

    protected function game_getPartyIds_v1 () :Array
    {
        return []; // no parties in the test env.
    }

    protected function player_getPartyId_v1 (playerId :int) :int
    {
        return 0; // no parties in the test env.
    }

    // Embed some media to be used as default headshots
    [Embed(source="../../../../../../../rsrc/images/headshots/natto.png")]
    protected static const HEADSHOT_1 :Class;
    [Embed(source="../../../../../../../rsrc/images/headshots/weardd.png")]
    protected static const HEADSHOT_2 :Class;
}
}
