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


package com.whirled.contrib.platformer.net {

import flash.utils.ByteArray;

public class CutSceneMessage
    implements GameMessage
{
    public static const NAME :String = "cutscene";

    public static const INIT :int = 0;
    public static const START :int = 1;
    public static const PLAY :int = 2;
    public static const END :int = 3;
    public static const CLOSE :int = 4;

    public var type :int;

    public static function create (type :int) :CutSceneMessage
    {
        var msg :CutSceneMessage = new CutSceneMessage();
        msg.type = type;
        return msg;
    }

    public function get name () :String
    {
        return NAME;
    }

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());
        bytes.writeByte(type);
        return bytes;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        type = bytes.readByte();
    }
}
}
