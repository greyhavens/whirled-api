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

package com.whirled.contrib.platformer.board {

import com.threerings.util.ArrayIterator;
import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;

import com.whirled.contrib.platformer.piece.Actor;
import com.whirled.contrib.platformer.piece.Dynamic;
import com.whirled.contrib.platformer.piece.Piece;
import com.whirled.contrib.platformer.piece.PieceFactory;
import com.whirled.contrib.platformer.piece.Shot;

/**
 * The base class for a board which contains pieces.
 */
public class Board
{
    public static const PIECE_ADDED :String = "added";
    public static const PIECE_LOADED :String = "loaded";
    public static const PIECE_REMOVED :String = "removed";
    public static const ITEM_UPDATED :String = "updated";
    public static const ITEM_FORWARD :String = "forward";
    public static const ITEM_BACK :String = "back";
    public static const ITEM_UP :String = "up";
    public static const ITEM_DOWN :String = "down";
    public static const GROUP_ADDED :String = "group_added";
    public static const ITEM_REMOVED :String = "item_removed";
    public static const ACTOR_ADDED :String = "actor_added";
    public static const SHOT_ADDED :String = "shot_added";
    public static const DYNAMIC_ADDED :String = "dynamic_added";
    public static const DYNAMIC_REMOVED :String = "dynamic_removed";

    public static const ACTORS :int = 0;
    public static const PLATFORMS :int = 1;

    public static const GROUP_NAMES :Array = [ "actors", "platforms" ];

    public function loadFromXML (level :XML, pfac :PieceFactory) :void
    {
        _pfac = pfac;
        if (level == null) {
            _xml = <platformer><board/></platformer>;
        } else {
            _xml = level;
        }
        if (boardHas("piecenode")) {
            loadPieceTree(_xml.board[0].piecenode[0], _pieceTree);
        } else {
            _pieceTree.push("root");
            _pieceTree.push([ "front" ]);
            _pieceTree.push([ "back" ]);
        }
        _dynamicIns[ACTORS] = new Array();
        if (boardHas("actors")) {
            loadDynamics(_xml.board[0].actors[0], _dynamicIns[ACTORS]);
        }
        _dynamicIns[PLATFORMS] = new Array();
        if (boardHas("platforms")) {
            loadDynamics(_xml.board[0].platforms[0], _dynamicIns[PLATFORMS]);
        }
        if (boardHas("spawns")) {
            loadSpawns(_xml.board[0].spawns[0], _spawns);
        }
    }

    public function getDynamicIns (idx :int) :Array
    {
        return _dynamicIns[idx];
    }

    public function getActors () :Array
    {
        return _actors;
    }

    public function getSpawn (idx :int) :Array
    {
        return (_spawns[idx] == null) ? [11, 11] : _spawns[idx];
    }

    public function addActor (a :Actor) :void
    {
        trace("adding actor " + a.sprite + " at (" + a.x + ", " + a.y + ")");
        a.id = ++_actorId;
        _actors.push(a);
        sendEvent(ACTOR_ADDED, a, "");
    }

    public function addDynamic (d :Dynamic) :void
    {
        d.id = ++_actorId;
        _dynamics.push(d);
        trace("adding dynamic " + d.id + " at (" + d.x + ", " + d.y + ")");
        sendEvent(DYNAMIC_ADDED, d, "");
    }

    public function hasActor (a :Actor) :Boolean
    {
        return _actors.indexOf(a) != -1;
    }

    public function addDynamicIns (d :Dynamic, idx :int) :void
    {
        _dynamicIns[idx].push(d);
        adjustMaxId(d);
        sendEvent(DYNAMIC_ADDED, d, "root." + GROUP_NAMES[idx]);
    }

    public function updateDynamicIns (d :Dynamic, idx :int) :void
    {
        if (_dynamicIns[idx].indexOf(d) != -1) {
            sendEvent(ITEM_UPDATED, d, "root." + GROUP_NAMES[idx]);
        }
    }

    public function addShot (s :Shot) :void
    {
        _shots.push(s);
        sendEvent(SHOT_ADDED, s, "");
    }

    public function removeDynamic (d :Dynamic) :void
    {
        var arr :Array = _shots;
        if (d is Actor) {
            arr = _actors;
        }
        var idx :int = arr.indexOf(d);
        if (idx != -1) {
            arr.splice(idx, 1);
        }
        sendEvent(DYNAMIC_REMOVED, d, "");
    }

    public function addPiece (p :Piece, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        arr.push(p);
        if (_maxId < p.id) {
            _maxId = p.id;
        }
        sendEvent(PIECE_ADDED, p, tree);
    }

    public function addPieceGroup (tree :String, name :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        var group :Array = new Array();
        group.push(name);
        arr.push(group);
        sendEvent(GROUP_ADDED, name, tree);
    }

    public function getItem (name :String, tree :String) :Object
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return null;
        }
        for (var ii :int = 0; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                return arr[ii];
            }
        }
        return null;

    }

    public function removeItem (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        for (var ii :int = 0; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                arr.splice(ii--, 1);
            }
        }
        sendEvent(ITEM_REMOVED, name, tree);
    }

    public function moveItemForward (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        var item :Object;
        for (var ii :int = 1; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                if (ii + 1 < arr.length) {
                    item = arr[ii];
                    arr[ii] = arr[ii + 1];
                    arr[ii + 1] = item;
                }
                break;
            }
        }
        if (item != null) {
            sendEvent(ITEM_FORWARD, name, tree);
        }
    }

    public function moveItemBack (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        var item :Object;
        for (var ii :int = 1; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                if (ii > 1) {
                    item = arr[ii];
                    arr[ii] = arr[ii - 1];
                    arr[ii - 1] = item;
                }
                break;
            }
        }
        if (item != null) {
            sendEvent(ITEM_BACK, name, tree);
        }
    }

    public function moveItemUp (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        var up :Array = getGroup(tree.substr(0, tree.lastIndexOf(".")));
        if (arr == null || up == null) {
            return;
        }
        var item :Object;
        for (var ii :int = 1; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                item = arr[ii];
                arr.splice(ii, 1);
                break;
            }
        }
        if (item != null) {
            var idx :int = up.indexOf(arr);
            up.splice(idx, 0, item);
            sendEvent(ITEM_UP, name, tree);
        }
    }

    public function moveItemDown (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        var item :Object;
        var newarr :Array;
        for (var ii :int = 1; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                item = arr[ii];
                break;
            }
        }
        if (item == null) {
            return;
        }
        for (var jj :int = ii + 1; jj < arr.length; jj++) {
            if (arr[jj] is Array) {
                newarr = arr[jj];
                break;
            }
        }
        if (newarr != null) {
            arr.splice(ii, 1);
            newarr.splice(1, 0, item);
            sendEvent(ITEM_DOWN, name, tree);
        }
    }

    public function flipPiece (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        for each (var item :Object in arr) {
            if (item is Piece && item.id.toString() == name) {
                var p :Piece = item as Piece;
                p.orient = 1 - p.orient;
                sendEvent(ITEM_UPDATED, p, tree);
            }
        }
    }

    protected function isItem (item :Object, name :String) :Boolean
    {
        return ((item is Piece || item is Dynamic) && item.id.toString() == name) ||
                (item is Array && item[0] == name);
    }

    public function getPieces () :Array
    {
        return _pieceTree;
    }

    protected function getGroup (tree :String) :Array
    {
        tree = tree.replace(/root(\.)*/, "");
        for (var ii :int = 0; ii < GROUP_NAMES.length; ii++) {
            if (tree == GROUP_NAMES[ii]) {
                return _dynamicIns[ii];
            }
        }
        var arr :Array = _pieceTree;
        for each (var name :String in tree.split(".")) {
            if (name == "") {
                continue;
            }
            for each (var node :Object in arr) {
                if (node is Array && node[0] == name) {
                    arr = node as Array;
                    break;
                }
                node = null;
            }
            if (node == null) {
                return null;
            }
        }
        return arr;
    }

    public function getBackgroundXML () :XML
    {
        if (boardHas("background")) {
            return _xml.board[0].background[0];
        }
        return null;
    }

    public function getXML () :XML
    {
        addOrReplaceXML(_xml.board[0], "piecenode", getPieceTreeXML());
        for (var ii :int = 0; ii < GROUP_NAMES.length; ii++) {
            addOrReplaceXML(_xml.board[0], GROUP_NAMES[ii], getDynamicsXML(ii));
        }
        return _xml;
    }

    public function getPieceTreeXML () :XML
    {
        return genPieceTreeXML(_pieceTree);
    }

    public function getDynamicsXML (idx :int) :XML
    {
        return genDynamicsXML(_dynamicIns[idx], GROUP_NAMES[idx]);
    }

    public function loadDynamic (xml :XML) :Dynamic
    {
        var dclass :Class = ClassUtil.getClassByName("piece." + xml.@type);
        if (dclass != null) {
            trace("creating dynamic: " + xml.@type);
            return new dclass(xml);
        }
        return null;
    }

    protected function loadPieceTree (xml :XML, arr :Array) :void
    {
        arr.push(xml.@name.toString());
        for each (var node :XML in xml.children()) {
            if (node.localName() == "piece") {
                var p :Piece = _pfac.getPiece(node);
                arr.push(p);
                if (_maxId < p.id) {
                    _maxId = p.id;
                }
                sendEvent(PIECE_LOADED, p, "");
            } else {
                var child :Array = new Array();
                loadPieceTree(node, child);
                arr.push(child);
            }
        }
    }

    protected function loadDynamics (xml :XML, arr :Array) :void
    {
        trace("Loading dynamics");
        for each (var node :XML in xml.children()) {
            var d :Dynamic = loadDynamic(node);
            if (d != null) {
                adjustMaxId(d);
                arr.push(d);
            }
        }
    }

    protected function loadSpawns (xml :XML, arr :Array) :void
    {
        for each (var node :XML in xml.children()) {
            arr.push([ node.@x, node.@y ]);
        }
    }

    protected function addOrReplaceXML (source:XML, nodename :String, node :XML) :void
    {
        if (source.child(nodename).length() > 0) {
            source.replace(nodename, node);
        } else {
            source.appendChild(node);
        }
    }

    protected function genPieceTreeXML (pieces :Array) :XML
    {
        var node :XML = <piecenode/>;
        for each (var item :Object in pieces) {
            if (item is Array) {
                node.appendChild(genPieceTreeXML(item as Array));
            } else if (item is Piece) {
                node.appendChild(item.xmlInstance());
            } else {
                node.@name = item;
            }
        }
        return node;
    }

    protected function genDynamicsXML (dynamics :Array, nodename :String) :XML
    {
        var node :XML = new XML("<" + nodename + "/>");
        for each (var dyn :Dynamic in dynamics) {
            node.appendChild(dyn.xmlInstance());
        }
        return node;
    }

    public function getMaxId () :int
    {
        return _maxId;
    }

    public function addEventListener (eventName :String, callback :Function) :void
    {
        var _callbacks :Array = _listeners.get(eventName);
        if (_callbacks == null) {
            _listeners.put(eventName, _callbacks = new Array());
        }
        if (_callbacks.indexOf(callback) == -1) {
            _callbacks.push(callback);
        }
    }

    public function removeEventListener (eventName :String, callback :Function) :void
    {
        var _callbacks :Array = _listeners.get(eventName);
        if (_callbacks == null) {
            return;
        }
        var idx :int = _callbacks.indexOf(callback);
        if (idx == -1) {
            return;
        }
        _callbacks.splice(idx, 1);
    }

    protected function sendEvent (eventName :String, ... args) :void
    {
        var _callbacks :Array = _listeners.get(eventName);
        if (_callbacks == null) {
            return;
        }
        _callbacks.forEach(function (callback :*, index :int, array :Array) :void {
            (callback as Function)(args[0], args[1]);
        });
    }

    protected function boardHas (child :String) :Boolean
    {
        return _xml.board[0].child(child).length() > 0;
    }

    protected function adjustMaxId (d :Dynamic) :void
    {
        if (_maxId < d.id) {
            _maxId = d.id;
        }
    }

    /** The XML definition. */
    protected var _xml :XML;

    /** All the pieces on the board. */
    protected var _pieceTree :Array = new Array();
    protected var _maxId :int;
    protected var _actorId :int;

    protected var _actors :Array = new Array();
    protected var _dynamics :Array = new Array();
    protected var _dynamicIns :Array = new Array();
    protected var _shots :Array = new Array();
    protected var _spawns :Array = new Array();

    protected var _listeners :HashMap = new HashMap();

    protected var _pfac :PieceFactory;
}
}
