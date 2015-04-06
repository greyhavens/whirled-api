//
// $Id$

package com.whirled.game.client;

import java.io.Externalizable;
import java.io.Serializable;

import java.lang.reflect.Array;

import java.util.HashMap;

import com.samskivert.util.CompactIntListUtil;
import com.samskivert.util.ObserverList;
import com.samskivert.util.StringUtil;

import com.threerings.util.MessageBundle;
import com.threerings.util.Name;

import com.threerings.presents.client.InvocationService;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.util.CrowdContext;

import com.whirled.game.data.PropertySpaceObject;
import com.whirled.game.data.WhirledGameObject;
import com.whirled.game.server.PropertySpaceHelper;
import com.whirled.game.util.ObjectMarshaller;

import com.whirled.game.WhirledGame;
import com.whirled.game.WhirledGameEvent;
import com.whirled.game.DealListener;
import com.whirled.game.MessageReceivedEvent;
import com.whirled.game.MessageReceivedListener;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.PropertyChangedListener;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.StateChangedListener;

import com.whirled.game.data.WhirledGameCodes;

import static com.whirled.game.Log.log;

public class GameObjectImpl
    implements WhirledGame
{
    public GameObjectImpl (CrowdContext ctx, WhirledGameObject gameObj)
    {
        _ctx = ctx;
        _gameObj = gameObj;
        _props = _gameObj.getUserProps();
    }

    // from WhirledGame
    public Object get (String propName)
    {
        return _props.get(propName);
    }

    // from WhirledGame
    public Object get (String propName, int index)
    {
        return ((Object[]) get(propName))[index];
    }

    // from WhirledGame
    public void set (String propName, Object value)
    {
        set(propName, value, -1);
    }

    // from WhirledGame
    public void set (String propName, Object value, int index)
    {
        validatePropertyChange(propName, value, -1);

        Object encoded = ObjectMarshaller.encode(value);
        Object reconstituted = ObjectMarshaller.decode(encoded);
        _gameObj.propertyService.setProperty(
            _ctx.getClient(), propName, encoded, index, false, false, null,
            createLoggingListener("setProperty"));

        // set it immediately in the game object
        try {
            PropertySpaceHelper.applyPropertySet(_gameObj, propName, reconstituted, index, false);
        } catch (PropertySpaceObject.PropertySetException pse) {
            throw new RuntimeException(pse);
        }
    }

    // from WhirledGame
    public void testAndSet (String propName, Object value, Object testValue)
    {
        testAndSet(propName, value, testValue, -1);
    }

    // from WhirledGame
    public void testAndSet (
        String propName, Object value, Object testValue, int index)
    {
        validatePropertyChange(propName, value, -1);

        Object encoded = ObjectMarshaller.encode(value);
        _gameObj.propertyService.setProperty(
            _ctx.getClient(), propName, encoded, null, false, true, testValue,
            createLoggingListener("testAndSet"));
    }

    // from WhirledGame
    public void registerListener (Object obj)
    {
        if ((obj instanceof MessageReceivedListener) ||
            (obj instanceof PropertyChangedListener) ||
            (obj instanceof StateChangedListener)) {

            // silently ignore requests to listen twice
            if (!_listeners.contains(obj)) {
                _listeners.add(obj);
            }
        }
    }

    // from WhirledGame
    public void unregisterListener (Object obj)
    {
        _listeners.remove(obj);
    }

    // from WhirledGame
    public void setCollection (String collName, Object values)
    {
        populateCollection(collName, values, true);
    }

    // from WhirledGame
    public void addToCollection (String collName, Object values)
    {
        populateCollection(collName, values, false);
    }

    // from WhirledGame
    public void pickFromCollection (
        String collName, int count, String propName)
    {
        getFromCollection(collName, count, propName, -1, false, null);
    }

    // from WhirledGame
    public void pickFromCollection (
        String collName, int count, String msgName, int playerIndex)
    {
        getFromCollection(collName, count, msgName, playerIndex, false, null);
    }

    // from WhirledGame
    public void dealFromCollection (
        String collName, int count, String propName,
        DealListener listener)
    {
        getFromCollection(collName, count, propName, -1, true, listener);
    }

    // from WhirledGame
    public void dealFromCollection (
        String collName, int count, String msgName,
        DealListener listener, int playerIndex)
    {
        getFromCollection(collName, count, msgName, playerIndex, true, listener);
    }

    // from WhirledGame
    public void mergeCollection (String srcColl, String intoColl)
    {
        validateName(srcColl);
        validateName(intoColl);
        _gameObj.whirledGameService.mergeCollection(_ctx.getClient(),
            srcColl, intoColl, createLoggingListener("mergeCollection"));
    }

    // from WhirledGame
    public void sendMessage (String messageName, Object value)
    {
        sendMessage(messageName, value, -1);
    }

    // from WhirledGame
    public void sendMessage (String messageName, Object value, int playerIndex)
    {
        validateName(messageName);
        validateValue(value);

        Object encoded = ObjectMarshaller.encode(value);
        if (playerIndex == -1) {
            _gameObj.messageService.sendMessage(_ctx.getClient(),
                messageName, encoded, createLoggingListener("sendMessage"));

        } else {
            _gameObj.messageService.sendPrivateMessage(_ctx.getClient(),
                messageName, encoded, new int [] {playerIndex},
                createLoggingListener("sendMessage"));
        }
    }

    // from WhirledGame
    public void startTicker (String tickerName, int msOfDelay)
    {
        validateName(tickerName);
        _gameObj.whirledGameService.setTicker(_ctx.getClient(),
            tickerName, msOfDelay, createLoggingListener("setTicker"));
    }

    // from WhirledGame
    public void stopTicker (String tickerName)
    {
        startTicker(tickerName, 0);
    }

    // from WhirledGame
    public void sendChat (String msg)
    {
        validateChat(msg);
        // Post a message to the game object, the controller
        // will listen and call localChat().
        _gameObj.postMessage(WhirledGameObject.GAME_CHAT, new Object[] { msg });
    }

    // from WhirledGame
    public void localChat (String msg)
    {
        validateChat(msg);
        // messages displayed with sendChat will end up
        _ctx.getChatDirector().displayInfo(
            null, MessageBundle.taint(msg), WhirledGameCodes.USERGAME_CHAT_TYPE);
    }

    // from WhirledGame
    public int getPlayerCount ()
    {
        return _gameObj.getPlayerCount();
    }

    // from WhirledGame
    public String[] getPlayerNames ()
    {
        String[] names = new String[_gameObj.players.length];
        int index = 0;
        for (Name name : _gameObj.players) {
            names[index++] = (name == null) ? null : name.toString();
        }
        return names;
    }

    // from WhirledGame
    public int getMyIndex ()
    {
        return _gameObj.getPlayerIndex(getUsername());
    }

    // from WhirledGame
    public int getTurnHolderIndex ()
    {
        return _gameObj.getPlayerIndex(_gameObj.turnHolder);
    }

    // from WhirledGame
    public int[] getWinnerIndexes ()
    {
        int[] winners = new int[0];
        if (_gameObj.winners != null) {
            for (int ii = 0; ii < _gameObj.winners.length; ii++) {
                if (_gameObj.winners[ii]) {
                    winners = CompactIntListUtil.add(winners, ii);
                }
            }
        }
        return winners;
    }

    // from WhirledGame
    public boolean isMyTurn ()
    {
        return getUsername().equals(_gameObj.turnHolder);
    }

    // from WhirledGame
    public boolean isInPlay ()
    {
        return _gameObj.isInPlay();
    }

    // from WhirledGame
    public void endTurn ()
    {
        endTurn(-1);
    }

    // from WhirledGame
    public void endTurn (int nextPlayerIndex)
    {
        _gameObj.whirledGameService.endTurn(_ctx.getClient(), nextPlayerIndex,
            createLoggingListener("endTurn"));
    }

    // from WhirledGame
    public void endGame (int[] winnerIds, int[] loserIds, int payoutType)
    {
        _gameObj.whirledGameService.endGameWithWinners(
            _ctx.getClient(), winnerIds, loserIds, payoutType, createLoggingListener("endGame"));
    }

    /**
     * Secret function to dispatch property changed events.
     */
    void dispatch (WhirledGameEvent event)
    {
        ObserverList.ObserverOp<Object> op;

        if (event instanceof PropertyChangedEvent) {
            final PropertyChangedEvent pce = (PropertyChangedEvent) event;
            op = new ObserverList.ObserverOp<Object>() {
                public boolean apply (Object obs) {
                    if (obs instanceof PropertyChangedListener) {
                        ((PropertyChangedListener) obs).propertyChanged(pce);
                    }
                    return true;
                }
            };

        } else if (event instanceof StateChangedEvent) {
            final StateChangedEvent sce = (StateChangedEvent) event;
            op = new ObserverList.ObserverOp<Object>() {
                public boolean apply (Object obs) {
                    if (obs instanceof StateChangedListener) {
                        ((StateChangedListener) obs).stateChanged(sce);
                    }
                    return true;
                }
            };

        } else if (event instanceof MessageReceivedEvent) {
            final MessageReceivedEvent mre = (MessageReceivedEvent) event;
            op = new ObserverList.ObserverOp<Object>() {
                public boolean apply (Object obs) {
                    if (obs instanceof MessageReceivedListener) {
                        ((MessageReceivedListener) obs).messageReceived(mre);
                    }
                    return true;
                }
            };

        } else {
            throw new IllegalArgumentException("Please implement");
        }

        // and apply the operation
        _listeners.apply(op);
    }

    /**
     * Convenience function to get our name.
     */
    private Name getUsername ()
    {
        BodyObject body = (BodyObject) _ctx.getClient().getClientObject();
        return body.getVisibleName();
    }

    /**
     * Create a listener for service requests.
     */
    private InvocationService.ConfirmListener createLoggingListener (
        final String service)
    {
        return new InvocationService.ConfirmListener() {
            public void requestFailed (String cause)
            {
                log.warning("Service failure " +
                    "[service=" + service + ", cause=" + cause + "].");
            }

            public void requestProcessed ()
            {
                // nada
            }
        };
    }

    /**
     * Helper method for setCollection and addToCollection.
     */
    private void populateCollection (
        String collName, Object values, boolean clearExisting)
    {
        validateName(collName);
        if (values == null) {
            throw new IllegalArgumentException(
                "Collection values may not be null.");
        }
        validateValue(values);

        byte[][] encodedValues = (byte[][]) ObjectMarshaller.encode(values);

        _gameObj.whirledGameService.addToCollection(
            _ctx.getClient(), collName, encodedValues, clearExisting,
            createLoggingListener("populateCollection"));
    }

    /**
     * Helper method for pickFromCollection and dealFromCollection.
     */
    private void getFromCollection(
        String collName, final int count, String msgOrPropName, int playerIndex,
        boolean consume, final DealListener dealy)
    {
        validateName(collName);
        validateName(msgOrPropName);
        if (count < 1) {
            throw new IllegalArgumentException(
                "Must retrieve at least one element!");
        }

        InvocationService.ConfirmListener listener;
        if (dealy != null) {
            // TODO: Figure out the method sig of the callback, and what it
            // means
            listener = new InvocationService.ConfirmListener() {
                public void requestFailed (String cause) {
                    try {
                        dealy.dealt(0);
                    } catch (NumberFormatException nfe) {
                        // nada
                    }
                }

                public void requestProcessed () {
                    dealy.dealt(count);
                }
            };

        } else {
            listener = createLoggingListener("getFromCollection");
        }

        _gameObj.whirledGameService.getFromCollection(
            _ctx.getClient(), collName, consume, count, msgOrPropName,
            playerIndex, listener);
    }

    /**
     * Verify that the property name / value are valid.
     */
    private void validatePropertyChange (
        String propName, Object value, int index)
    {
        validateName(propName);

        // check that we're setting an array element on an array
        if (index >= 0) {
            if (!(get(propName) instanceof Object[])) {
                throw new IllegalArgumentException("Property " + propName +
                    " is not an Array.");
            }
        }

        // validate the value too
        validateValue(value);
    }

    /**
     * Verify that the specified name is valid.
     */
    private void validateName (String name)
    {
        if (name == null) {
            throw new IllegalArgumentException(
                "Property, message, and collection names must not be null.");
        }
    }

    private void validateChat (String msg)
    {
        if (StringUtil.isBlank(msg)) {
            throw new IllegalArgumentException(
                "Empty chat may not be displayed.");
        }
    }

    /**
     * Verify that the value is legal to be streamed to other clients.
     */
    private void validateValue (Object value)
    {
        if (value == null) {
            return;

        } else if (value instanceof Externalizable) {
            throw new IllegalArgumentException(
                "IExternalizable is not yet supported");

        } else if (value.getClass().isArray()) {
            int length = Array.getLength(value);
            for (int ii=0; ii < length; ii++) {
                validateValue(Array.get(value, ii));
            }

        } else if (value instanceof Iterable<?>) {
            for (Object o : (Iterable<?>) value) {
                validateValue(o);
            }

        } else if (!(value instanceof Serializable)) {
            throw new IllegalArgumentException(
                "Non-serializable properties may not be set.");
        }
    }

    protected CrowdContext _ctx;

    protected WhirledGameObject _gameObj;

    protected HashMap<String, Object> _props;

    protected ObserverList<Object> _listeners =
        new ObserverList<Object>(ObserverList.SAFE_IN_ORDER_NOTIFY);
}
