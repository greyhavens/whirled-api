//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.util.ClassUtil;
import com.threerings.util.StreamableHashMap;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.crowd.client.PlaceController;

import com.threerings.parlor.game.client.GameConfigurator;
import com.threerings.parlor.game.data.GameConfig;

/**
 * A game config for a simple multiplayer whirled game.
 */
public class BaseGameConfig extends GameConfig
{
    /** Our configuration parameters. These will be seeded with the defaults from the game
     * definition and then configured by the player in the lobby. */
    public var params :StreamableHashMap = new StreamableHashMap(String);

    public function BaseGameConfig (gameId :int = 0, gameDef :GameDefinition = null)
    {
        _gameId = gameId;
        _gameDef = gameDef;
    }

    /** Returns the game definition associated with this config instance. */
    public function getGameDefinition () :GameDefinition
    {
        return _gameDef;
    }

    // from GameConfig
    override public function getGameId () :int
    {
        return _gameId;
    }

    // from GameConfig
    override public function getGameIdent () :String
    {
        return _gameDef.ident;
    }

    // from GameConfig
    override public function getMatchType () :int
    {
        return _gameDef.match.getMatchType();
    }

    // from GameConfig
    override public function createConfigurator () :GameConfigurator
    {
        return null;
    }

    // from abstract PlaceConfig
    override public function getManagerClassName () :String
    {
        throw new Error("Not implemented.");
    }

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        params = StreamableHashMap(ins.readObject());
        _gameId = ins.readInt();
        _gameDef = GameDefinition(ins.readObject());
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(params);
        out.writeInt(_gameId);
        out.writeObject(_gameDef);
    }

    // from PlaceConfig
    override public function createController () :PlaceController
    {
        // TODO: for this to really work with server side code, the choice of controller
        // will need to refer to the type of client (flash or thane) that we are running on
        var controller :String = getGameDefinition().controller;
        if (controller == null) {
            return createDefaultController();
        }
        var c :Class = ClassUtil.getClassByName(controller);
        return (new c() as PlaceController);
    }

    /**
     * Creates the controller to be used if the game definition does not specify a custom
     * controller. This is abstract since the controller must be specifically a thane
     * or flash controller.
     */
    protected /*abstract*/ function createDefaultController () :PlaceController
    {
        throw new Error("abstract");
    }

    /** Our game's unique id. */
    protected var _gameId :int;

    /** Our game definition. */
    protected var _gameDef :GameDefinition;
}
}
