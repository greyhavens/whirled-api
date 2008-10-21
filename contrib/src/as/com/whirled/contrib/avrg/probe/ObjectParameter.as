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

package com.whirled.contrib.avrg.probe {

/**
 * Parameter type for automatically parsing any basic actionscript object type. This is a
 * relatively full-featured parser and can handle nestings of different object types and separator
 * characters embedded in strings. For example, a dictionary that maps "A" to an array of
 * dictionaries and maps "3" to null: {"A":[{"]":"foo", "}":bar", "bang":"howdy"}], 3: null}
 */
public class ObjectParameter extends Parameter
{
    /**
     * Creates a new object parameter.
     * @param name the name of the parameter
     * @param flahs optional flags to pass to the superclass
     */
    public function ObjectParameter (name :String, flags :uint=0)
    {
        super(name, Object, flags);
    }

    /** @inheritDoc */
    // from Parameter
    override public function get typeDisplay () :String
    {
        return "Object";
    }

    /** @inheritDoc */
    // from Parameter
    override public function parse (input :String) :Object
    {
        return parseObject(input, 0);
    }

    protected var _underlying :Class;
}

}

import flash.utils.Dictionary;
import com.whirled.contrib.avrg.probe.Parameter;

class ParseError extends Error
{
    public function ParseError (input :String, pos :int, thing :String = null)
    {
        
        super(thing == null ? "Unexpected characters at column " + (pos + 1) + ": " + 
              input.slice(pos) : "Expected " + thing + " at column " + (pos + 1) + ": " +
              input.slice(pos));
    }
}

function readInt (input :String, pos :int) :String
{
    var next :int = pos;
    while (next < input.length) {
        if (!Parameter.isDigit(input.charAt(next))) {
            break;
        }
        ++next;
    }
    return input.slice(pos, next);
}

function readId (input :String, pos :int) :String
{
    var next :int = pos;
    if (!Parameter.isAlpha(input.charAt(next++))) {
        throw new ParseError(input, pos, "identifier character");
    }

    while (next < input.length) {
        var test :String = input.charAt(next);
        if (!Parameter.isAlpha(test) && !Parameter.isDigit(test)) {
            break;
        }
        ++next;
    }

    return input.slice(pos, next);
}

function readString (input :String, pos :int) :String
{
    if (input.charAt(pos) != "\"") {
        throw new ParseError(input, pos, "double quote");
    }
    var next :int = pos + 1;
    while (next < input.length) {
        if (input.charAt(next) == "\"") {
            break;
        }
        ++next;
    }
    if (next == input.length) {
        throw new ParseError(input, next, "double quote");
    }

    return input.slice(pos, next + 1);
}

class ValueWrapper
{
    public var value :Object;

    public function ValueWrapper (value :Object)
    {
        this.value = value;
    }
}

class ParseStack
{
    public function peekState (depth :int=0) :int
    {
        return _states[length - 1 - depth];
    }

    public function peekHasValue (depth :int=0) :Boolean
    {
        return _values[length - 1 - depth] != null;
    }

    public function peekValue (depth :int=0) :Object
    {
        return _values[length - 1 - depth].value;
    }

    public function poke (obj :Object) :void
    {
        _values[_values.length - 1] = new ValueWrapper(obj);
    }

    public function push (state :int) :void
    {
        _states.push(state);
        _values.push(null);
    }

    public function pop () :void
    {
        _states.pop();
        _values.pop();
    }

    public function get length () :int
    {
        return _states.length;
    }

    protected var _states :Array = [];
    protected var _values :Array = [];
}

const OBJECT: int = 0;
const ARRAY_OPEN :int = 1;
const ARRAY_TAIL :int = 2;
const DICT_OPEN :int = 3;
const DICT_SEP :int = 4;
const DICT_TAIL :int = 5;

function parseObject (input :String, pos :int) :Object
{
    var stack :ParseStack = new ParseStack();
    stack.push(OBJECT);
    
    while (pos < input.length) {
        var next :String = input.charAt(pos);
        if (Parameter.isWhitespace(next)) {
            ++pos;
            continue;
        }

        switch (stack.peekState()) {
        case OBJECT:
            if (stack.peekHasValue()) {
                throw new ParseError(input, pos);
            }
            if (next == "{") {
                stack.poke(new Dictionary());
                stack.push(DICT_OPEN);
                pos++;
 
            } else if (next == "[") {
                stack.poke([]);
                stack.push(ARRAY_OPEN);
                pos++;

            } else if (next == "\"") {
                var str :String = readString(input, pos);
                stack.poke(str.slice(1, str.length - 1));
                pos += str.length;

            } else if (Parameter.isDigit(next)) {
                var i :String = readInt(input, pos);
                stack.poke(parseInt(i));
                pos += i.length;

            } else if (next == "n" && readId(input, pos) == "null") {
                stack.poke(null);
                pos += 4;

            } else {
                throw new ParseError(input, pos, "object");
            }
            break;

        case DICT_OPEN:
            if (next == "}") {
                stack.pop();
                pos++;

            } else if (Parameter.isDigit(next)) {
                var key :String = readInt(input, pos);
                stack.poke(parseInt(key));
                stack.push(DICT_SEP);
                pos += key.length;

            } else {
                var name :String = readId(input, pos);
                stack.poke(name);
                stack.push(DICT_SEP);
                pos += name.length;
            }
            break;
            
        case DICT_SEP:
            if (next == ":") {
                stack.pop();
                stack.push(OBJECT);
                pos++;

            } else {
                throw new ParseError(input, pos, "colon");
            }
            break;

        case DICT_TAIL:
            if (next == ",") {
                stack.pop();
                stack.push(DICT_OPEN);
                pos++;

            } else if (next == "}") {
                stack.pop();
                pos++;

            } else {
                throw new ParseError(input, pos, "comma or close brace");
            }
            break;

        case ARRAY_OPEN:
            if (next == "]") {
                stack.pop();
                pos++;

            } else {
                stack.push(OBJECT);
            }
            break;

        case ARRAY_TAIL:
            if (next == ",") {
                stack.pop();
                stack.push(ARRAY_OPEN);
                pos++;

            } else if (next == "]") {
                stack.pop();
                pos++;

            } else {
                throw new ParseError(input, pos, "comma or close bracket");
            }
            break;
        }

        if (stack.peekState() == OBJECT &&
            stack.peekHasValue() &&
            stack.length > 1) {
            switch (stack.peekState(1)) {
            case DICT_OPEN:
                var value :Object = stack.peekValue(0);
                var name2 :Object = stack.peekValue(1) as Object;
                var dict :Object = stack.peekValue(2);
                dict[name2] = value;
                stack.pop();
                stack.pop();
                stack.push(DICT_TAIL);
                break;
            case ARRAY_OPEN:
            case ARRAY_TAIL:
                var elem :Object = stack.peekValue(0);
                var array :Object = stack.peekValue(2);
                array.push(elem);
                stack.pop();
                stack.pop();
                stack.push(ARRAY_TAIL);
                break;
            }
        }
    }

    if (stack.length > 1) {
        throw new ParseError(input, input.length, "closing characters");
    }

    if (!stack.peekHasValue()) {
        throw new ParseError(input, 0, "object");
    }

    return stack.peekValue();
}

