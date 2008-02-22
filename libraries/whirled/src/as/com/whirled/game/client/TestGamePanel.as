//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.geom.Rectangle;

import mx.containers.HBox;
import mx.containers.VBox;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.flex.ChatControl;
import com.threerings.flex.ChatDisplayBox;
import com.threerings.flex.CommandLinkButton;

import com.threerings.parlor.game.data.GameObject;

/**
 * Handles the main game view for test games.
 */
public class TestGamePanel extends WhirledGamePanel
{
    public function TestGamePanel (ctx :CrowdContext, ctrl :TestGameController)
    {
        super(ctx, ctrl);

        styleLinkButton(_backToLobby);
        styleLinkButton(_backToWhirled);

        // have us take up the entire size of our parent
        percentWidth = 100;
        percentHeight = 100;

        _ctrlBar = new HBox();
        _ctrlBar.setStyle("backgroundColor", 0x000000);
        _ctrlBar.setStyle("horizontalAlign", "right");
        _ctrlBar.setStyle("paddingRight", 10);
        addChild(_ctrlBar);

        addChild(_playerList);

        var chat :ChatDisplayBox = new ChatDisplayBox(ctx);
        chat.percentWidth = 100;
        chat.percentHeight = 100;

        var control :ChatControl = new ChatControl(ctx);
        _chatBox = new VBox();
        _chatBox.addChild(chat);
        _chatBox.addChild(control);
        addChild(_chatBox);
    }

    override public function willEnterPlace (plobj :PlaceObject) :void
    {
        super.willEnterPlace(plobj);

        _ctrlBar.addChild(_rematch);
        _ctrlBar.addChild(_backToLobby);
        _ctrlBar.addChild(_backToWhirled);
    }

    override public function didLeavePlace (plobj :PlaceObject) :void
    {
        _ctrlBar.removeChild(_backToLobby);
        _ctrlBar.removeChild(_backToWhirled);
        _ctrlBar.removeChild(_rematch);

        super.didLeavePlace(plobj);
    }

    override protected function getButtonLabels (plobj :PlaceObject) :Array
    {
        var gameObj :GameObject = plobj as GameObject;
        return [ "Leave game", "Game lobby",
            ((gameObj.players.length == 1) ? "Play again" : "Request a rematch") ];
    }

    override protected function configureGameView (view :GameContainer) :void
    {
        // we don't call super because super sets percentWidth and percentHeight which fucks things
        // right on up; force games to 700x500 as that's what we want for whirled
        view.width = 700;
        view.height = 500;
    }

    // from Container
    override protected function updateDisplayList (
        unscaledWidth :Number, unscaledHeight :Number) :void
    {
        const GAP :int = 14;
        const SIDEBAR_WIDTH :int = 300;
        const CTRLBAR_HEIGHT :int = 24;

        _ctrlBar.x = 0;
        _ctrlBar.y = unscaledHeight - CTRLBAR_HEIGHT;
        _ctrlBar.width = unscaledWidth - GAP - SIDEBAR_WIDTH;
        _ctrlBar.height = CTRLBAR_HEIGHT;

        _gameView.width = unscaledWidth - GAP - SIDEBAR_WIDTH;
        _gameView.height = unscaledHeight - CTRLBAR_HEIGHT;
        _playerList.x = unscaledWidth - SIDEBAR_WIDTH;
        _playerList.width = SIDEBAR_WIDTH - GAP;

        _chatBox.x = unscaledWidth - SIDEBAR_WIDTH;
        _chatBox.y = _playerList.y + _playerList.height + GAP;
        _chatBox.width = SIDEBAR_WIDTH - GAP;
        _chatBox.height = unscaledHeight - _chatBox.y;

        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }

    /**
     * Style the link buttons so they don't look like ass.
     */
    protected function styleLinkButton (btn :CommandLinkButton) :void
    {
        btn.setStyle("overSkin", null);
        btn.setStyle("downSkin", null);
        btn.setStyle("color", 0xAAB5B9);
        btn.setStyle("textRollOverColor", 0xAAB5B9);
        btn.setStyle("textSelectedColor", 0xAAB5B9);
    }

    protected var _chatBox :VBox;

    protected var _ctrlBar :HBox;
}
}