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
import com.threerings.ezgame.client.EZGameBackend;
import com.threerings.ezgame.data.EZGameObject;

/**
 * Extends the basic EZGame backend with flow and other whirled services.
 */
public class TestGameBackend extends WhirledGameBackend
{
    public function TestGameBackend (
        ctx :CrowdContext, ezObj :EZGameObject, ctrl :TestGameController, panel :TestGamePanel)
    {
        super(ctx, ezObj, ctrl);
        _panel = panel;
    }

    override protected function populateProperties (o :Object) :void
    {
        super.populateProperties(o);

//         o["getHeadShot_v1"] = getHeadShot; // TODO: fake up a sprite
    }

    protected var _panel :TestGamePanel;
}
}