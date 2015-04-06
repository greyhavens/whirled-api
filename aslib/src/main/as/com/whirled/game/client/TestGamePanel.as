//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.display.Sprite;

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

    override protected function displayGameOver (gameOver :Boolean) :void
    {
//        // in the test environment, we simply add or remove the rematch button from the
//        // control bar... even if our caller made it invisible!
//        if (gameOver == (_rematch.parent != null)) {
//            return; // we're already displaying the right state
//        }
//        if (gameOver) {
//            _ctrlBar.addChild(_rematch);
//        } else {
//            _ctrlBar.removeChild(_rematch);
//        }
    }

    override protected function getRematchLabel (plobj :PlaceObject) :String
    {
        var gameObj :GameObject = plobj as GameObject;
        return (gameObj.players.length == 1) ? "Play again" : "Request a rematch";
    }

    override protected function configureGameView (view :GameBox) :void
    {
        // we don't call super because super sets percentWidth and percentHeight which fucks things
        // right on up; force games to 700x500 as that's what we want for whirled
        view.width = GAME_WIDTH;
        view.height = GAME_HEIGHT;

        var mask :Sprite = new Sprite();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, GAME_WIDTH, GAME_HEIGHT);
        mask.graphics.endFill();
        view.mask = mask;
        view.rawChildren.addChild(mask);
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
        _ctrlBar.width = unscaledWidth;
        _ctrlBar.height = CTRLBAR_HEIGHT;

        // Note: It might be nice to have a bar along the top to make the gameView not be at y=0,
        // which would force game developers to realize that x and y are not global.
        // X is probably enough though.
        _gameView.x = SIDEBAR_WIDTH + GAP;
        _gameView.y = 0;
        _gameView.width = unscaledWidth - (SIDEBAR_WIDTH + GAP);
        _gameView.height = unscaledHeight - CTRLBAR_HEIGHT;

        _playerList.x = 0;
        _playerList.y = 0;
        _playerList.width = SIDEBAR_WIDTH;

        _chatBox.x = 0;
        _chatBox.y = _playerList.y + _playerList.height + GAP;
        _chatBox.width = SIDEBAR_WIDTH;
        _chatBox.height = unscaledHeight - _chatBox.y;

        super.updateDisplayList(unscaledWidth, unscaledHeight);
    }

    protected var _chatBox :VBox;

    protected var _ctrlBar :HBox;
}
}
