//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.client {

import flash.display.Loader;
import flash.display.Stage;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.Dictionary;

import com.threerings.crowd.util.CrowdContext;
import com.threerings.ezgame.client.GameControlBackend;
import com.threerings.ezgame.data.EZGameObject;

/**
 * Extends the basic EZGame backend with flow and other whirled services.
 */
public class TestGameControlBackend extends WhirledGameControlBackend
{
    public function TestGameControlBackend (
        ctx :CrowdContext, ezObj :EZGameObject, ctrl :TestGameController, panel :TestGamePanel)
    {
        super(ctx, ezObj, ctrl);
        _panel = panel;
    }

    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

        var ctrl :TestGameController = (_ctrl as TestGameController);
        o["setChatEnabled_v1"] = _panel.setChatEnabled;
        o["setChatBounds_v1"] = _panel.setChatBounds;
//         o["getHeadShot_v1"] = getHeadShot; // TODO: fake up a sprite
        o["getStageBounds_v1"] = getStageBounds;
        o["backToWhirled_v1"] = backToWhirled;
        o["getLevelPacks_v1"] = getLevelPacks;
        o["getItemPacks_v1"] = getItemPacks;
        o["getPlayerItemPacks_v1"] = getPlayerItemPacks;
    }

    protected function getStageBounds () :Rectangle
    {
        return _panel.getStageBounds();
    }

    protected function backToWhirled () :void
    {
        _ctx.getClient().logoff(false);
    }

    protected function getLevelPacks () :Array
    {
        return []; // TODO: how to test level packs
    }

    protected function getItemPacks () :Array
    {
        return []; // TODO: how to test item packs
    }

    protected function getPlayerItemPacks (occupant :int) :Array
    {
        return []; // TODO: how to test item packs
    }

    protected var _panel :TestGamePanel;
}
}
