//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.presents.dobj.SetListener;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.crowd.util.CrowdContext;
import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.data.BodyObject;
import com.threerings.parlor.game.data.GameConfig;

/**
 * A controller for flash games.
 */
public class WhirledGameController extends BaseGameController
    implements SetListener
{
    public function WhirledGameController ()
    {
    }

    /**
     * Is this game a party game?
     */
    public function isParty () :Boolean
    {
        return (_gconfig.getMatchType() == GameConfig.PARTY);
    }

    // from SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            _panel.checkGameOverDisplay();
        }
    }

    // from SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            _panel.checkGameOverDisplay();
        }
    }

    // from SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        // nada
    }

    /** @inheritDoc */
    // from BaseGameController
    override public function userCodeIsConnected (autoReady :Boolean) :void
    {
        super.userCodeIsConnected(autoReady);

        // Every occupant should call occupntInRoom, but if we end up calling playerReady()
        // then that suffices.
        if (autoReady) {
            var bobj :BodyObject = (_ctx.getClient().getClientObject() as BodyObject);
            const isPlayer :Boolean = isParty() ||
                (_gobj.getPlayerIndex(bobj.getVisibleName()) != -1);
            if (isPlayer) {
                playerIsReady();
                return;
            }
            // else, we're not a player, so fall through...
        }

        // either we're just an observer, or autoReady is false
        _gobj.manager.invoke("occupantInRoom");
    }

    // from BaseGameController
    override protected function createBackend () :BaseGameBackend
    {
        return new WhirledGameBackend(_ctx, _gameObj, this);
    }

    // from GameController
    override protected function gameDidStart () :void
    {
        super.gameDidStart();
        _panel.checkGameOverDisplay();
    }

    // from GameController
    override protected function gameDidEnd () :void
    {
        super.gameDidEnd();
        _panel.checkGameOverDisplay();
    }

    // from PlaceController
    override protected function createPlaceView (ctx :CrowdContext) :PlaceView
    {
        return new WhirledGamePanel(ctx, this);
    }

    // from PlaceController
    override protected function didInit () :void
    {
        super.didInit();

        // we can't just assign _panel in createPlaceView() for some exciting reason
        _panel = (_view as WhirledGamePanel);
    }

    protected var _panel :WhirledGamePanel;
}
}
