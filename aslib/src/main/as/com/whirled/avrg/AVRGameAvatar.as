//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.avrg {

import flash.geom.Rectangle;

/**
 * Describes the current state of a player's avatar for an AVRG client or server agent.
 * @see RoomSubControlBase#getAvatarInfo()
 */
public class AVRGameAvatar
{
    /** The entity id of the player's avatar.
     * @see RoomSubControlClient#getEntityProperty */
    public var entityId :String;

    /** The avatar's current state. These are the same states that appear on the avatar's "Change
     * state" menu. */
    public var state :String;

    /** The x position of the avatar's registration point, measured in room coordinates.
     * @see http://wiki.whirled.com/Coordinate_systems */
    public var x :Number;

    /** The y position of the avatar's registration point, measured in room coordinates.
     * @see http://wiki.whirled.com/Coordinate_systems */
    public var y :Number;

    /** The z position of the avatar's registration point, measured in room coordinates.
     * @see http://wiki.whirled.com/Coordinate_systems */
    public var z :Number;

    /** The orientation of the avatar, measured in counter-clockwise degrees from front facing. If
     * the avatar is facing towards the player's screen, the orientation is 0. Facing to the right,
     * 90&deg;, to the rear 180&deg; and to the left 270&deg;.*/
    public var orientation :int;

    /** The avatar's move speed, in pixels per second.
     *
     * <p>NOTE: this value is not available for server agents. Avatars are considered to arrive
     * immediately at their destinations. */
    public var moveSpeed :Number;

    /** Whether the avatar is currently moving.
     *
     * <p>NOTE: this value is always false for server agents. Avatars are considered to arrive
     * immediately at their destinations.</p> */
    public var isMoving :Boolean;

    /** Whether the avatar is currently idle. Player avatars automatically go into this state after
     * not moving the mouse over the browser or flash player window for a few minutes.*/
    public var isIdle :Boolean;

    /** The bounding rectangle of the avatar, in pixels. This is in the same coodinates as the
     * paintable area returned by the <code>LocalSubControl</code>. For example an avatar on the
     * left side of a normal room will have a <code>bounds.left</code> near zero.
     * @see LocalSubControl#getPaintableArea()
     */
    public var bounds :Rectangle;
}
}
