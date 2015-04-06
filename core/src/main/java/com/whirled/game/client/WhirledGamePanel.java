//
// $Id$

package com.whirled.game.client;

import java.awt.Component;

import java.awt.event.ContainerEvent;
import java.awt.event.ContainerListener;

import java.util.WeakHashMap;

import javax.swing.JPanel;

import com.samskivert.swing.VGroupLayout;
import com.samskivert.swing.util.SwingUtil;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.whirled.game.data.WhirledGameObject;

import com.whirled.game.Game;

public class WhirledGamePanel extends JPanel
    implements ContainerListener, PlaceView
{
    public WhirledGamePanel (CrowdContext ctx, WhirledGameController ctrl)
    {
        super(new VGroupLayout(VGroupLayout.STRETCH));

        _ctx = ctx;
        _ctrl = ctrl;

        // add a listener so that we hear about all new children
        addContainerListener(this);

// TODO: sort out if and how Whirled games will create their views
//         WhirledGameConfig cfg = (WhirledGameConfig) ctrl.getPlaceConfig();
//         try {
//             _gameView = (Component) Class.forName(cfg.gameMedia).newInstance();
//             add(_gameView);
//         } catch (RuntimeException re) {
//             throw re;

//         } catch (Exception e) {
//             throw new RuntimeException(e);
//         }

        // TODO: Add a standard chat display?
        //addChild(new ChatDisplayBox(ctx));
    }

    // from PlaceView
    public void willEnterPlace (final PlaceObject plobj)
    {
        // don't start notifying anything of the game until we've
        // notified the game manager that we're in the game
        // (done in GameController, and it uses callLater, so we do it twice!)
        _ctx.getClient().getRunQueue().postRunnable(new Runnable() {
            public void run () {
                _ctx.getClient().getRunQueue().postRunnable(new Runnable() {
                    public void run () {
                        _gameObj = (WhirledGameObject) plobj;
                        notifyOfGame(_gameView);
                    }
                });
            }
        });
    }

    // from PlaceView
    public void didLeavePlace (PlaceObject plobj)
    {
        removeListeners(_gameView);
        _gameObj = null;
    }

    // from ContainerListener
    public void componentAdded (ContainerEvent event)
    {
        if (_gameObj != null) {
            notifyOfGame(event.getChild());
        }
    }

    // from ContainerListener
    public void componentRemoved (ContainerEvent event)
    {
        if (_gameObj != null) {
            removeListeners(event.getChild());
        }
    }

    /**
     * Find any children of the specified object that implement
     * com.metasoy.game.Game and provide them with the GameObject.
     */
    protected void notifyOfGame (Component root)
    {
        SwingUtil.applyToHierarchy(root, new SwingUtil.ComponentOp() {
            public void apply (Component comp) {
                if (comp instanceof Game) {
                    // only notify the Game if we haven't seen it before
                    // TODO: what we really want is a weak identity map,
                    // so that two keys that are equals() do not collide.
                    if (null == _seenGames.put(comp, Boolean.TRUE)) {
                        ((Game) comp).setGameObject(_ctrl.gameObjImpl);
                    }
                }
                // always check to see if it's a listener
                _ctrl.gameObjImpl.registerListener(comp);
            }
        });
    }

    protected void removeListeners (Component root)
    {
        SwingUtil.applyToHierarchy(root, new SwingUtil.ComponentOp() {
            public void apply (Component comp) {
                _ctrl.gameObjImpl.unregisterListener(comp);
            }
        });
    }

    protected CrowdContext _ctx;
    protected WhirledGameController _ctrl;

    protected Component _gameView;

    /** A weak-key hash of the Game interfaces we've already seen. */
    protected WeakHashMap<Component, Boolean> _seenGames =
        new WeakHashMap<Component, Boolean>();

    protected WhirledGameObject _gameObj;
}
