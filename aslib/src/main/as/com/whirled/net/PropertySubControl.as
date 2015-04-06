//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.net {

public interface PropertySubControl extends PropertyGetSubControl
{
    /**
     * Set a property value to be distributed to the other clients in this game.
     * Property values can be any of the primitive types: int, uint, Number, Boolean, String,
     * ByteArray; or you may set Arrays, Dictionarys, or plain old Objects, as long as
     * the values within them are primitive types or other Arrays, Dictionarys and Objects.
     *
     * <p>You may not set your own classes as properties. However, you can serialize your data
     * into a ByteArray and set that.</p>
     *
     * <p><b>Note</b>: top-level Dictionarys must have int keys, the intention is to use
     * occupantIds as keys.</p>
     *
     * <p>Note that if you set the value as an Array or Dictionary, the value is serialized
     * slightly differently in order to enable updating individual elements efficiently.
     * The individual elements will be serialized separately. You may update the elements
     * individually by using either setAt (for Arrays) or setIn (for Dictionarys). The
     * effect of serializing elements individually is that references to the same object will
     * not be reconstructed off the network as references to the same object. See the example
     * below.</p>
     *
     * @param propName the name of the property to set.
     * @param value the value to set. Passing null clears the property.
     * @param immediate if true, the value is updated immediately in the local object. Otherwise
     * any old value will remain in effect until the PropertyChangedEvent arrives after
     * a round-trip to the server.
     *
     * @example
     * <listing version="3.0">
     * // demonstrates expert-level difference between setting values in an array and an object.
     * var o :Object = { blue: true };
     * var objTest :Object = { 0: o, 1: o};
     * var arrayTest :Array = [ o, o ];
     * _ctrl.net.set("object", objTest);
     * _ctrl.net.set("array", arrayTest);
     *
     * // Later, when reading those values back out:
     * var obj :Object = _ctrl.net.get("object");
     * var array :Array = _ctrl.net.get("array") as Array;
     * trace("array: " + (array[0] == array[1])); // traces false
     * trace("object: " + (obj[0] == obj[1])); // traces true
     * </listing>
     *
     * @example
     * <listing version="3.0">
     * // demonstrates potentially surprising results when immediate=true
     * _ctrl.set("myProp", 1, true);
     * _ctrl.set("myProp", 2, true);
     *
     * // Some time later, a PropertyChangedEvent will come back from the server, changing
     * // "myProp" back to 1 very briefly, before the second PropertyChangedEvent occurs
     * // and sets it to 2 again.
     *
     * _ctrl.set("myProp", int(_ctrl.get("myProp")) + 1, true);
     *
     * // If the above line is executed after the first PropertyChangedEvent arrives, but
     * // before the second, myProp's final value will be 2. If it's executed after the second
     * // event arrives, myProps final value will be 3.
     *
     * trace(_ctrl.get("myProp")); // might trace "2", might trace "3"
     * </listing>
     *
     * @see Array
     * @see flash.utils.Dictionary
     * @see #setAt()
     * @see #setIn()
     */
    function set (propName :String, value :Object, immediate :Boolean = false) :void;

    /**
     * Update one element of an Array.<br/>
     * <b>Note</b>: Unlike setIn(), this update will fail silently if the index is out of
     * bounds or if there is no array currently set at the specified property name.
     * Furthermore, if you set the element with immediate=true, there are two updates:
     * one locally that happens right away and the update on the server that will be
     * dispatched back to all the clients. Either or both can fail, so be sure to set the Array up
     * first using set().
     *
     * @param propName the name of the property to modify.
     * @param index the array index of the element to update.
     * @param value the value to set.
     * @param immediate if true, the value is updated immediately in the local object. Otherwise
     * any old value will remain in effect until the ElementChangedEvent arrives after
     * a round-trip to the server.
     *
     * @see #set()
     */
    function setAt (propName :String, index :int, value :Object, immediate :Boolean = false) :void;

    /**
     * Update one element of a Dictionary.<br/>
     * <b>Note</b>: Unlike setAt(), this will usually work. No key is out of range, obviously,
     * and if you set a value in a property that was previously null, a new Dictionary will
     * be created to hold your value. If a non-Dictionary property is already stored with the
     * specified name then this will fail silently on the server. But: don't do that!
     * It would be pretty bad style to store two different types of property under the same name.
     *
     * @param propName the name of the property to modify.
     * @param key the key of the element to update.
     * @param value the value to set. Passing null removes the specified key from the Dictionary.
     * @param immediate if true, the value is updated immediately in the local object. Otherwise
     * any old value will remain in effect until the ElementChangedEvent arrives after
     * a round-trip to the server.
     */
    function setIn (propName :String, key :int, value :Object, immediate :Boolean = false) :void;

    /**
     * @copy com.whirled.AbstractControl#doBatch()
     */
    function doBatch (fn :Function, ... args) :void;
}
}
