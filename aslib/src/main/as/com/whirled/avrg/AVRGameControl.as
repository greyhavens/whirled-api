//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import flash.display.DisplayObject;

import com.threerings.util.Log;

import com.whirled.AbstractControl;
import com.whirled.ServerObject;

/**
 * This file should be included by AVR game clients so that they can communicate with their server
 * agent and the whirled.
 *
 * AVRGame means: Alternate Virtual Reality Game, and refers to games
 * played within the whirled environment with your avatar.
 *
 * <p>AVR games can be significantly more complicated than lobbied games. Please consult the whirled
 * wiki section on AVRGs as well as the AVRG discussion forum if you're having any problems.</p>
 *
 * @see http://wiki.whirled.com/AVR_Games
 * @see http://www.whirled.com/#whirleds-d_135
 */
public class AVRGameControl extends AbstractControl
{
    /**
     * Creates a new game control for an AVR game client.
     */
    public function AVRGameControl (disp :DisplayObject)
    {
        super(disp);

        if (disp is ServerObject) {
            throw new Error("AVRGameControl should not be instantiated with a ServerObject");
        }

        // set up the default hitPointTester
        _local.setHitPointTester(disp.root.hitTestPoint);
    }

    /**
     * Accesses the client's game sub control.
     */
    public function get game () :GameSubControlClient
    {
        return _game;
    }

    /**
     * Accesses the client's room sub control for the player's current room.
     */
    public function get room () :RoomSubControlClient
    {
        return _room;
    }

    /**
     * Accesses the client's local player sub control.
     */
    public function get player () :PlayerSubControlClient
    {
        return _player;
    }

    /**
     * Accesses the client's local sub control.
     */
    public function get local () :LocalSubControl
    {
        return _local;
    }

    /**
     * Accesses the client's agent sub control.
     */
    public function get agent () :AgentSubControl
    {
        return _agent;
    }

    /** @private */
    override public function setUserProps (o :Object) :void
    {
        super.setUserProps(o);
        o["requestMobSprite_v1"] = requestMobSprite_v1;
        o["leftRoom_v1"] = leftRoom_v1;
        o["enteredRoom_v1"] = enteredRoom_v1;
    }

    /** @private */
    override protected function createSubControls () :Array
    {
        return [
            _game = new GameSubControlClient(this),
            _room = new RoomSubControlClient(this),
            _player = new PlayerSubControlClient(this),
            _local = new LocalSubControl(this),
            _agent = new AgentSubControl(this),
        ];
    }

    /** @private */
    protected function requestMobSprite_v1 (id :String) :DisplayObject
    {
        var ctrl :MobSubControlClient = MobSubControlClient(_room.getMobSubControl(id));
        if (ctrl != null) {
            // TODO: this is not actually OK, the control should be nuked when we move
            return ctrl.getMobSprite();
        }
        if (_local.mobSpriteExporter == null) {
            Log.getLog(this).warning(
                "Sprite requested but control has no exporter [id=" + id + "]");
            return null;
        }
        var sprite :DisplayObject = _local.mobSpriteExporter(id) as DisplayObject;
        Log.getLog(this).debug("Requested sprite [id=" + id + ", sprite=" + sprite + "]");
        if (sprite != null) {
            var delayEvent :Boolean = false;
            _room.setMobSubControl(id, new MobSubControlClient(this, id, sprite), delayEvent);
        }
        return sprite;
    }

    /** @private */
    internal function leftRoom_v1 (scene :int) :void
    {
        _player.leftRoom_v1(scene);
        _room.leftRoom();
    }

    /** @private */
    internal function enteredRoom_v1 (scene :int) :void
    {
        _player.enteredRoom_v1(scene);
    }

    /** @private */
    protected var _game :GameSubControlClient;

    /** @private */
    protected var _room :RoomSubControlClient;

    /** @private */
    protected var _player :PlayerSubControlClient;

    /** @private */
    protected var _local :LocalSubControl;

    /** @private */
    protected var _agent :AgentSubControl;
}
}

import flash.display.DisplayObject;

import com.whirled.avrg.MobSubControlClient;

class MobEntry
{
    public var control :MobSubControlClient;

    public function MobEntry (control :MobSubControlClient, sprite :DisplayObject)
    {
        this.control = control;
    }
}
