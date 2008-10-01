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

package com.whirled.contrib.platformer.game {

import com.whirled.contrib.platformer.piece.Actor;

/**
 * An event trigger that occurs when all the supplied actor ids are dead.
 */
public class DeathEventTrigger extends EventTrigger
{
    public function DeathEventTrigger (gctrl :GameController, xml :XML)
    {
        super(gctrl, xml);
        var ids :String = xml.@ids;
        _ids = new Array();
        for each (var id :int in ids.split(/,/)) {
            _ids.push(id);
        }
        trace("new Death Trigger " + _ids.join(","));
    }

    override public function checkTriggered () :Boolean
    {
        if (hasTriggered()) {
            return true;
        }
        var ii :int;
        while (ii < _ids.length) {
            var a :Actor = _gctrl.getBoard().getActor(_ids[ii]);
            if (a == null || a.health <= 0) {
                _ids.splice(ii, 1);
            } else {
                ii++;
            }
        }
        if (_ids.length == 0) {
            _triggered = true;
        }
        return _triggered;
    }

    protected var _ids :Array;
}
}
