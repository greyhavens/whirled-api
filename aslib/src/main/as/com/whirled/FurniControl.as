//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled {

import flash.display.DisplayObject;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;

/**
 * Dispatched when the local user hovers the mouse over this sprite.
 * Note that normal MouseEvents are blocked when this sprite has "action", like it
 * is a doorway. If you want the doorway to react to the mouse being over it then
 * you should listen for this event.
 *
 * @eventType com.whirled.ControlEvent.HOVER_OVER
 */
[Event(name="hoverOver", type="com.whirled.ControlEvent")]

/**
 * Dispatched when the local user unhovers the mouse from this sprite.
 * Note that normal MouseEvents are blocked when this sprite has "action", like it
 * is a doorway. If you want the doorway to react to the mouse being over it then
 * you should listen for this event.
 *
 * @eventType com.whirled.ControlEvent.HOVER_OVER
 */
[Event(name="hoverOut", type="com.whirled.ControlEvent")]

/**
 * This file should be included by furniture, so that it can communicate
 * with the whirled.
 */
public class FurniControl extends EntityControl
{
    /** An action triggered when someone arrives at the location at which
     * this furniture is placed, if this piece of furniture is a doorway.
     *
     * <p>This will arrive via an ACTION_TRIGGERED event with the name property set
     * to BODY_ENTERED.</p>
     */
    public static const BODY_ENTERED :String = "bodyEntered";

    /** An action triggered when someone leaves via this piece of doorway
     * furniture.
     *
     * <p>This will arrive via an ACTION_TRIGGERED event with the name property set
     * to BODY_LEFT.</p>
     */
    public static const BODY_LEFT :String = "bodyLeft";

    /**
     * Create a furni interface. The display object is your piece
     * of furni.
     */
    public function FurniControl (disp :DisplayObject)
    {
        super(disp);
        disp.root.addEventListener(MouseEvent.ROLL_OVER, handleMouseRoll);
        disp.root.addEventListener(MouseEvent.ROLL_OUT, handleMouseRoll);
    }

    /**
     * Shows the Whirled page identified by the supplied token.
     *
     * @param token the token that identifies the page to be shown. This is <em>not</em> the full
     * URL, just the part after http://www.whirled.com/#. For example: passing "me" would show the
     * Me page. Passing "shop-l_5_343" would show the shop page for the Kawaii Knight avatar.
     *
     * @return true if the page was shown, false if it could not be shown for some reason.
     */
    public function showPage (token :String) :Boolean
    {
        return callHostCode("showPage_v1", token);
    }

    /**
     * @private
     */
    override public function setUserProps (o :Object) :void
    {
        super.setUserProps(o);

        o["mouseHover_v1"] = mouseHover_v1;
    }

    /**
     * Dispatches hover events.
     * @private
     */
    protected function mouseHover_v1 (over :Boolean) :void
    {
        dispatchCtrlEvent(over ? ControlEvent.HOVER_OVER : ControlEvent.HOVER_OUT);
    }

    /**
     * @private
     */
    protected function handleMouseRoll (event :MouseEvent) :void
    {
        // when we don't have action in whirled, we need to hand-dispatch these events
        // but when we do have action, we won't receive normal mouse events and we'll be
        // getting our HOVERs from whirled.
        mouseHover_v1(event.type == MouseEvent.ROLL_OVER);
    }
}
}
