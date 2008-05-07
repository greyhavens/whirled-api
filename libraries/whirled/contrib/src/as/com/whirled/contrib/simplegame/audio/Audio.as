// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id$

package com.whirled.contrib.simplegame.audio {

import flash.media.Sound;

public class Audio
{
    public static function createChannel (sound :Sound = null, parentControls :AudioControllerContainer = null) :GameSoundChannel
    {
        return new GameSoundChannel(null != parentControls ? parentControls :masterControls).sound(sound);
    }

    public static function play (sound :Sound, parentControls :AudioControllerContainer = null) :GameSoundChannel
    {
        var gsm :GameSoundChannel = createChannel(sound, parentControls);
        gsm.play();
        return gsm;
    }

    public static function createControls (parentControls :AudioControllerContainer = null) :AudioControllerContainer
    {
        return new AudioControllerContainer(null != parentControls ? parentControls : masterControls);
    }

    public static function get masterControls () :AudioControllerContainer
    {
        if (null == g_masterControls) {
            g_masterControls = new AudioControllerContainer();
            g_masterControls.volume(0.5);
        }

        return g_masterControls;
    }

    protected static var g_masterControls :AudioControllerContainer;
}

}
