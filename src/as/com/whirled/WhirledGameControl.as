//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc.  Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;
import flash.geom.Rectangle;

import com.threerings.ezgame.EZGameControl;

/**
 * Adds whirled-specific controls to EZGameControl
 */
public class WhirledGameControl extends EZGameControl
{
    /**
     * Creates a control and connects to the Whirled game system.
     *
     * @param disp the display object that is the game's UI.
     * @param autoReady if true, the game will automatically be started when initialization is
     * complete, if false, the game will not start until all clients call playerReady().
     *
     * @see com.threerings.ezgame.EZGameControl#playerReady()
     */
    public function WhirledGameControl (disp :DisplayObject, autoReady :Boolean = true)
    {
        super(disp, autoReady);
    }

    /**
     * Grant a flow award to the player. The score is any number. The id is related to the score
     * or null if you only have one scoring event for your game.
     *
     * @return the amount of flow actually awarded.
     */
    public function grantFlowAward (score :Number, id :String = null) :int
    {
        return int(callEZCode("awardFlow_v2", score, id));
    }

    /**
     * Enables or disables chat. When chat is disabled, it is not visible which is useful for games
     * in which the chat overlay obstructs the view during play.
     */
    public function setChatEnabled (enabled :Boolean) :void
    {
        callEZCode("setChatEnabled_v1", enabled);
    }

    /**
     * Relocates the chat overlay to the specified region. By default the overlay covers the entire
     * width of the display and the bottom 150 pixels or so.
     */
    public function setChatBounds (bounds :Rectangle) :void
    {
        callEZCode("setChatBounds_v1", bounds);
    }

    /**
     * Return the headshot image for the given occupant in the form of a Sprite object.
     *
     * The sprite are cached in the client backend so the user should not worry too much
     * about multiple requests for the same occupant.
     *
     * @param callback signature: function (sprite :Sprite, success :Boolean) :void
     */
    public function getHeadShot (occupant :int, callback :Function) :void
    {
        callEZCode("getHeadShot_v1", occupant, callback);
    }

    /**
     * Returns the bounds of the "stage" on which the game will be drawn. This is mainly useful for
     * the width and height so that the game can know how much area it has to cover, however the x
     * and y coordinates will also indicate the offset from the upper left of the stage of the view
     * rectangle that contains the game.
     *
     * TODO: the chat channel panel can be opened and closed during a game, so we need to dispatch
     * an event to let the game know in case it wants to do something special to handle that.
     */
    public function getStageBounds () :Rectangle
    {
        return Rectangle(callEZCode("getStageBounds_v1"));
    }

    /**
     * Instructs the game client to return to Whirled.
     */
    public function backToWhirled () :void
    {
        callEZCode("backToWhirled_v1");
    }
}
}
