//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import com.threerings.util.Name;

import com.threerings.presents.dobj.AttributeChangedEvent;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.parlor.game.client.GameController;
import com.threerings.parlor.game.data.GameObject;

import com.threerings.parlor.turn.client.TurnGameController;
import com.threerings.parlor.turn.client.TurnGameControllerDelegate;

import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.WhirledPlayerObject;

/**
 * A controller for whirled games.
 */
public class BaseGameController extends GameController
    implements TurnGameController
{
    /** The game object backend. */
    public var backend :BaseGameBackend;

    public function BaseGameController ()
    {
        addDelegate(_turnDelegate = new TurnGameControllerDelegate(this));
    }

    /**
     * This is called by the backend once it has initialized and made contact with usercode.
     */
    public function userCodeIsConnected (autoReady :Boolean) :void
    {
        // do nothing by default
    }

    /**
     * Called by the backend when the game is ready to start. If the game has ended, this can
     * be called by all clients to start the game anew.
     */
    public function playerIsReady () :void
    {
        playerReady();
    }

    // from PlaceController
    override public function willEnterPlace (plobj :PlaceObject) :void
    {
        _gameObj = (plobj as WhirledGameObject);

        backend = createBackend();

        super.willEnterPlace(plobj);
    }

    // from PlaceController
    override public function didLeavePlace (plobj :PlaceObject) :void
    {
        super.didLeavePlace(plobj);

        backend.shutdown();

        _gameObj = null;
    }

    // from TurnGameController
    public function turnDidChange (turnHolder :Name) :void
    {
        backend.turnDidChange();
    }

    /**
     * Creates the backend object that will handle requests from user code.
     */
    protected /*abstract*/ function createBackend () :BaseGameBackend
    {
        throw new Error("abstract");
    }

    // from GameController
    override protected function shouldAutoPlayerReady (bobj :BodyObject) :Boolean
    {
        // we don't want to auto-player ready in willEnterPlace(), we'll do it ourselves after the
        // client code has connected
        return false;
    }

    // from GameController
    override public function attributeChanged (event :AttributeChangedEvent) :void
    {
        var name :String = event.getName();
        if (WhirledGameObject.CONTROLLER_ID == name) {
            backend.controlDidChange();
        } else if (WhirledGameObject.ROUND_ID == name) {
            if ((event.getValue() as int) > 0) {
                backend.roundStateChanged(true);
            } else {
                backend.roundStateChanged(false);
            }
        } else {
            super.attributeChanged(event);
        }
    }

    // from GameController
    override protected function gameDidStart () :void
    {
        super.gameDidStart();
        backend.gameStateChanged(true);
    }

    // from GameController
    override protected function gameDidEnd () :void
    {
        super.gameDidEnd();
        backend.gameStateChanged(false);
    }

    // from PlaceController
    override protected function createPlaceView (ctx :CrowdContext) :PlaceView
    {
        // we are viewless, subclasses need to do something here
        return super.createPlaceView(ctx);
    }

    protected var _gameObj :WhirledGameObject;
    protected var _turnDelegate :TurnGameControllerDelegate;

    // TODO: use this reference naturally (requires changes to msoy)
    WhirledPlayerObject; // free reference to force link
}
}
