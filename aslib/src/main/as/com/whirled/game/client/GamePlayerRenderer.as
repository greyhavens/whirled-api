//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.display.DisplayObject;

import mx.containers.HBox;

import mx.controls.Label;

import mx.core.ScrollPolicy;

import com.threerings.util.Name;

import com.whirled.ui.NameLabel;
import com.whirled.ui.NameLabelCreator;

import com.threerings.util.Log;

public class GamePlayerRenderer extends HBox
{
    /** A command event dispatched when a player name is clicked. */
    public static const PLAYER_CLICKED :String = "playerClicked";

    public function GamePlayerRenderer ()
    {
        super();

        verticalScrollPolicy = ScrollPolicy.OFF;
        horizontalScrollPolicy = ScrollPolicy.OFF;
        // the horizontalGap should be 8...
    }

    override public function set data (value :Object) :void
    {
        super.data = value;

        if (processedDescriptors) {
            configureUI();
        }
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        addChild(_scoreLabel = new Label());
        _scoreLabel.width = 90;

        configureUI();
    }

    /**
     * Update the UI elements with the data we're displaying.
     */
    protected function configureUI () :void
    {
        if (this.data != null && (this.data is Array) && (this.data as Array).length == 2) {
            var dataArray :Array = this.data as Array;
            var creator :NameLabelCreator = dataArray[0] as NameLabelCreator;
            var record :GamePlayerRecord = dataArray[1] as GamePlayerRecord;
            if (_currentName == null || !_currentName.equals(record.name) ||
                    _currentExtra != record.getExtraInfo() ||
                    _currentName.toString() != record.name.toString()) {
                if (_nameLabel != null && contains(DisplayObject(_nameLabel))) {
                    removeChild(DisplayObject(_nameLabel));
                }
                _currentName = record.name;
                _currentExtra = record.getExtraInfo();
                _nameLabel = creator.createLabel(_currentName, _currentExtra);
                addChildAt(DisplayObject(_nameLabel), 0);
                _nameLabel.percentWidth = 100;
            }
            _nameLabel.setStatus(record.status);
            _scoreLabel.text = (record.scoreData == null) ? "" : String(record.scoreData);
            _scoreLabel.setStyle("textAlign", (record.scoreData is Number) ? "right" : "left");

        } else {
            if (_nameLabel != null && contains(DisplayObject(_nameLabel))) {
                removeChild(DisplayObject(_nameLabel));
            }
            _nameLabel = null;
            _currentName = null;
            _scoreLabel.text = "";
        }
    }
    
    private static const log :Log = Log.getLog(GamePlayerRenderer);

    /** The label used to display the player's name. */
    protected var _nameLabel :NameLabel;

    /** The Name that is currently being displayed on the NameLable.  We only fetch a new label if
     * the Name changes. */
    protected var _currentName :Name;

    protected var _currentExtra :Object;

    /** The label used to display score data, if applicable. */
    protected var _scoreLabel :Label;
}
}
