//
// $Id$

package com.whirled.game.client;

import com.threerings.util.Name;

import com.threerings.presents.dobj.MessageListener;
import com.threerings.presents.dobj.MessageEvent;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.parlor.game.client.GameController;

import com.threerings.parlor.turn.client.TurnGameController;
import com.threerings.parlor.turn.client.TurnGameControllerDelegate;

import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.data.PropertySetEvent;
import com.whirled.game.data.PropertySetListener;
import com.whirled.game.data.WhirledPlayerObject;
import com.whirled.game.util.ObjectMarshaller;

import com.whirled.game.WhirledGameEvent;
import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.StateChangedEvent;

/**
 * A controller for flash games.
 */
public class WhirledGameController extends GameController
    implements TurnGameController, PropertySetListener, MessageListener
{
    /** The implementation of the GameObject interface for users. */
    public GameObjectImpl gameObjImpl;

    /**
     */
    public WhirledGameController ()
    {
        addDelegate(_turnDelegate = new TurnGameControllerDelegate(this));
    }

    @Override
    public void willEnterPlace (PlaceObject plobj)
    {
        _gameObj = (WhirledGameObject) plobj;
        gameObjImpl = new GameObjectImpl(_ctx, _gameObj);

        _ctx.getClient().getClientObject().addListener(_userListener);

        super.willEnterPlace(plobj);
    }

    @Override
    public void didLeavePlace (PlaceObject plobj)
    {
        super.didLeavePlace(plobj);

        _ctx.getClient().getClientObject().removeListener(_userListener);

        _gameObj = null;
    }

    // from TurnGameController
    public void turnDidChange (Name turnHolder)
    {
        dispatchUserEvent(
            new StateChangedEvent(gameObjImpl, StateChangedEvent.TURN_CHANGED));
    }

    // from PropertySetListener
    public void propertyWasSet (PropertySetEvent event)
    {
        // notify the user game
        dispatchUserEvent(new PropertyChangedEvent(
            gameObjImpl, event.getName(), event.getValue(),
            event.getOldValue(), -1));
    }

    // from MessageListener
    public void messageReceived (MessageEvent event)
    {
        String name = event.getName();
        if (WhirledGameObject.USER_MESSAGE.equals(name)) {
            dispatchUserMessage(event.getArgs());

        } else if (WhirledGameObject.GAME_CHAT.equals(name)) {
            // this is chat send by the game, let's route it like
            // localChat, which is also sent by the game
            gameObjImpl.localChat((String) event.getArgs()[0]);

        } else if (WhirledGameObject.TICKER.equals(name)) {
            Object[] args = event.getArgs();
            dispatchUserEvent(new MessageReceivedEvent(
                gameObjImpl, (String) args[0], (Integer) args[1]));
        }
    }

    /**
     * Dispatch the user message.
     */
    protected void dispatchUserMessage (Object[] args)
    {
        dispatchUserEvent(new MessageReceivedEvent(
            gameObjImpl, (String) args[0],
            ObjectMarshaller.decode(args[1])));
    }

    @Override
    protected PlaceView createPlaceView (CrowdContext ctx)
    {
        return new WhirledGamePanel(ctx, this);
    }

    @Override
    protected void gameDidStart ()
    {
        super.gameDidStart();
        dispatchUserEvent(
            new StateChangedEvent(gameObjImpl, StateChangedEvent.GAME_STARTED));
    }

    @Override
    protected void gameDidEnd ()
    {
        super.gameDidEnd();
        dispatchUserEvent(
            new StateChangedEvent(gameObjImpl, StateChangedEvent.GAME_ENDED));
    }

    protected void dispatchUserEvent (WhirledGameEvent event)
    {
        gameObjImpl.dispatch(event);
    }

    protected WhirledGameObject _gameObj;

    protected TurnGameControllerDelegate _turnDelegate;

    /** Listens for message events on the user object. */
    protected MessageListener _userListener = new MessageListener() {
        public void messageReceived (MessageEvent event) {
            // see if it's a message about user games
            if (WhirledPlayerObject.isFromGame(event.getName(), _gameObj.getOid())) {
                dispatchUserMessage(event.getArgs());
            }
        }
    };
}
