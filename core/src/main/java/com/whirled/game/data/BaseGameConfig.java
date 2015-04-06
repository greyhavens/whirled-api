//
// $Id$

package com.whirled.game.data;

import com.google.common.base.Preconditions;

import com.threerings.util.StreamableHashMap;

import com.threerings.crowd.client.PlaceController;

import com.threerings.parlor.game.client.GameConfigurator;
import com.threerings.parlor.game.data.GameConfig;

import com.whirled.game.client.WhirledGameConfigurator;

/**
 * A game config for a simple multiplayer game.
 */
public class BaseGameConfig extends GameConfig
{
    /** Our configuration parameters. These will be seeded with the defaults from the game
     * definition and then configured by the player in the lobby. */
    public StreamableHashMap<String,Object> params = new StreamableHashMap<String,Object>();

    /** A zero argument constructor used when unserializing. */
    public BaseGameConfig ()
    {
    }

    /** Constructs a game config based on the supplied game definition and optional parameters. */
    public BaseGameConfig (
        int gameId, GameDefinition gameDef, StreamableHashMap<String, Object> inParams)
    {
        Preconditions.checkNotNull(gameDef, "Missing GameDefinition");

        _gameId = gameId;
        _gameDef = gameDef;

        if (inParams != null) {
            // copy the given parameters
            params.putAll(inParams);

        } else if (gameDef.params != null) {
            // set the default values for our parameters
            for (int ii = 0; ii < gameDef.params.length; ii++) {
                params.put(gameDef.params[ii].ident, gameDef.params[ii].getDefaultValue());
            }
        }
    }

    /**
     * Returns the non-changing metadata that defines this game.
     */
    public GameDefinition getGameDefinition ()
    {
        return _gameDef;
    }

    @Override // from GameConfig
    public int getGameId ()
    {
        return _gameId;
    }

    @Override // from GameConfig
    public String getGameIdent ()
    {
        return _gameDef.ident;
    }

    @Override // from GameConfig
    public int getMatchType ()
    {
        return _gameDef.match.getMatchType();
    }

    @Override // from GameConfig
    public GameConfigurator createConfigurator ()
    {
        return new WhirledGameConfigurator();
    }

    @Override // from PlaceConfig
    public PlaceController createController ()
    {
        String ctrl = getGameDefinition().controller;
        if (ctrl == null) {
            throw new IllegalStateException("Game definition missing controller [gdef=" +
                getGameDefinition() + "]");
        }
        try {
            return (PlaceController) Class.forName(ctrl).newInstance();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override // from PlaceConfig
    public String getManagerClassName ()
    {
        return _gameDef.manager;
    }

    /** Our game's unique id. */
    protected int _gameId;

    /** Our game definition. */
    protected GameDefinition _gameDef;
}
