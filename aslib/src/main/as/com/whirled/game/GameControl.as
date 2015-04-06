//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game {

import flash.display.DisplayObject;

import flash.errors.IllegalOperationError;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import flash.geom.Point;

import com.whirled.AbstractControl;

/**
 * Used to coordinate game state and control your multiplayer game.
 * <br/><br/>
 * <b>Note:</b> Check out the
 * <a href="http://www.whirled.com/code/GameControl.html" target="_top">Easy GameControl Index</a>.
 * <br/><br/>
 *
 * @example Typically, you create this in your top-level MovieClip/Sprite:
 * <listing version="3.0">
 * public class MyGame extends Sprite
 * {
 *     public var ctrl :GameControl;
 *
 *     // Constructor
 *     public function MyGame ()
 *     {
 *          ctrl = new GameControl(this);
 *          ...
 * </listing>
 */
public class GameControl extends AbstractControl
{
    // Make item type codes available for in-game use
    public static const ITEM_PACK_SHOP :String = "item_packs";
    public static const LEVEL_PACK_SHOP :String = "level_packs";
    public static const AVATAR_SHOP :String = "avatars";
    public static const FURNITURE_SHOP :String = "furniture";
    public static const BACKDROP_SHOP :String = "backdrops";
    public static const TOY_SHOP :String = "toys";
    public static const PET_SHOP :String = "pets";

    /**
     * Creates a GameControl that connects to the Whirled game system.
     *
     * @param disp the display object that is the game's UI.
     * @param autoReady if true, the game will automatically be started when initialization is
     * complete, if false, the game will not start until all clients call playerReady().
     *
     * @see com.whirled.game.GameSubControl#playerReady()
     */
    public function GameControl (disp :DisplayObject, autoReady :Boolean = true)
    {
        super(disp, { autoReady_v1: autoReady });

        // set up our focusing click handler
        disp.root.addEventListener(MouseEvent.CLICK, handleRootClick);
    }

    /**
     * @inheritDoc
     */
    override public function isConnected () :Boolean
    {
        return _connected;
    }

    /**
     * Access the 'local' services.
     */
    public function get local () :LocalSubControl
    {
        return _localCtrl;
    }

    /**
     * Access the 'net' services.
     */
    public function get net () :NetSubControl
    {
        return _netCtrl;
    }

    /**
     * Access the 'player' services.
     */
    public function get player () :PlayerSubControl
    {
        return _playerCtrl;
    }

    /**
     * Access the 'game' services.
     */
    public function get game () :GameSubControl
    {
        return _gameCtrl;
    }

    /**
     * Access the 'services' services.
     */
    public function get services () :ServicesSubControl
    {
        return _servicesCtrl;
    }

    /**
     * Populate any properties or functions we want to expose to the other side of the whirled
     * security boundary.
     * @private
     */
    override public function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["connectionClosed_v1"] = connectionClosed_v1;
    }

    /**
     * Sets the properties we received from the host framework on the other side of the security
     * boundary.
     * @private
     */
    override public function gotHostProps (o :Object) :void
    {
        super.gotHostProps(o);

        // see if we're connected
        _connected = (o.gameData != null);
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            _localCtrl = new LocalSubControl(this),
            _netCtrl = new NetSubControl(this),
            _playerCtrl = new PlayerSubControl(this),
            _gameCtrl = new GameSubControl(this),
            _servicesCtrl = new ServicesSubControl(this)
        ];
    }

    /**
     * Internal method that is called whenever the mouse clicks our root.
     * @private
     */
    protected function handleRootClick (evt :MouseEvent) :void
    {
        if (!isConnected()) {
            return;
        }
        try {
            if (evt.target.stage == null || evt.target.stage.focus != null) {
                return;
            }
        } catch (err :SecurityError) {
        }
        callHostCode("focusContainer_v1");
    }

    /**
     * Private method called when the backend disconnects from us.
     */
    private function connectionClosed_v1 () :void
    {
        _connected = false;
    }

    /** Are we connected? @private */
    protected var _connected :Boolean;

    /** The local sub-control. @private */
    protected var _localCtrl :LocalSubControl;

    /** The net sub-control. @private */
    protected var _netCtrl :NetSubControl;

    /** The player sub-control. @private */
    protected var _playerCtrl :PlayerSubControl;

    /** The game sub-control. @private */
    protected var _gameCtrl :GameSubControl;

    /** The services sub-control. @private */
    protected var _servicesCtrl :ServicesSubControl;
}
}
