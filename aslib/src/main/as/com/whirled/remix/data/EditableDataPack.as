//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.remix.data {

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipOutput;

import com.whirled.BaseDataPack;
import com.whirled.DataPack;

import com.threerings.util.ArrayUtil;
import com.threerings.util.StringUtil;
import com.threerings.util.Util;
import com.threerings.util.ValueEvent;
import com.threerings.util.XmlUtil;

/**
 * Dispatched when a data field has changed.
 * value: data name
 *
 * @eventType com.whirled.remix.data.EditableDataPack.DATA_CHANGED
 */
[Event(name="dataChanged", type="com.threerings.util.ValueEvent")]

/**
 * Dispatched when a file field has changed.
 * value: file data name
 *
 * @eventType com.whirled.remix.data.EditableDataPack.FILE_CHANGED
 */
[Event(name="dataChanged", type="com.threerings.util.ValueEvent")]

public class EditableDataPack extends DataPack
{
    /** Exposed: the metadata filename (_data.xml) */
    public static const METADATA_FILENAME :String = BaseDataPack.METADATA_FILENAME;

    /**
     * @eventType dataChanged
     */
    public static const DATA_CHANGED :String = "dataChanged";

    /**
     * @eventType fileChanged
     */
    public static const FILE_CHANGED :String = "fileChanged";

    /**
     * Create an EditableDataPack.
     */
    public function EditableDataPack (urlOrByteArrayOrNothing :*)
    {
        // allow blank packs to be created
        if (urlOrByteArrayOrNothing != null) {
            super(urlOrByteArrayOrNothing);
        } else {
            _metadata = <datapack></datapack>;
        }
    }

    /**
     * Get a list of all the data fields.
     */
    public function getDataFields () :Array /* of String */
    {
        var list :XMLList = _metadata..data;
        var fields :Array = [];
        for each (var data :XML in list) {
            fields.push(unescape(data.@name));
        }
        return fields;
    }

    /**
     * Get a list of all the file fields.
     */
    public function getFileFields (includeContent :Boolean = false) :Array /* of String */
    {
        var list :XMLList = _metadata..file;

        var fields :Array = [];
        for each (var file :XML in list) {
            var name :String = file.@name;
            if (includeContent || (name != CONTENT_DATANAME)) {
                fields.push(unescape(name));
            }
        }
        return fields;
    }

    /**
     * Return an Object map containing information about the specified data entry.
     * Fields:
     *    name: [dataName]:String
     *    type: [typeOfData]:String
     *    info: [description]:String
     *    optional: [isOptional]:Boolean
     *    value: [objectValue]:*
     *    defaultValue: [objectValue]:*
     *    toString: [function] () :String // returns the latest value always!
     *    fromString: [function] (str :String) :Object // parses the value
     *
     * Additional optional fields:
     *    Type: Number and int
     *       min: [minimumValue]:Number
     *       max: [maximumValue]:Number
     *    Type: Choice
     *       choices: [stringValues]:Array
     */
    public function getDataEntry (name :String) :Object
    {
        name = validateAccess(name);

        var datum :XML = getDatum(_metadata..data, name);
        if (datum == null) {
            return null;
        }

        var theType :String = parseValue(datum, "type", "String");
        var entry :Object = {
            name: parseValue(datum, "name", "String"),
            type: theType,
            info: parseValue(datum, "info", "String"),
            optional: Boolean(parseValue(datum, "optional", "Boolean")),
            value: parseValue(datum),
            defaultValue: parseValue(datum, "defaultValue"),
            toString: function () :String {
                return extractStringValue(datum) as String;
            },
            fromString :function (str :String) :Object {
                return parseValueFromString(str, theType);
            }
        };

        switch (entry.type) {
        case "Number":
        case "int":
            entry.min = parseValue(datum, "min", "Number");
            entry.max = parseValue(datum, "max", "Number");
            break;

        case "Choice":
            entry.choices = parseValue(datum, "choices", "Array");
            break;
        }

        return entry;
    }

    /**
     * Return an Object map containing information about the specified file entry.
     * Fields:
     *    name: [fieldName]:String
     *    type: [typeOfFile]:String
     *    info: [description]:String
     *    optional: [isOptional]:Boolean
     *    value: [filename]:*
     *
     * Additional optional fields:
     *    Type: Image|DisplayObject
     *       width: [requiredWidth]:Number
     *       height: [requiredHeight]:Number
     *       maxWidth: [maxWidth]:Number
     *       maxHeight: [maxHeight]:Number
     */
    public function getFileEntry (name :String) :Object
    {
        name = validateAccess(name);

        var datum :XML = getDatum(_metadata..file, name);
        if (datum == null) {
            return null;
        }

        var entry :Object = {
            name: parseValue(datum, "name", "String"),
            type: parseValue(datum, "type", "String"),
            info: parseValue(datum, "info", "String"),
            optional: Boolean(parseValue(datum, "optional", "Boolean")),
            value: parseValue(datum, "value", "String")
        };

        switch (entry.type) {
        case "Image": // fall through to DisplayObject
        case "DisplayObject":
            entry.width = parseValue(datum, "width", "Number");
            entry.height = parseValue(datum, "height", "Number");
            entry.maxWidth = parseValue(datum, "maxWidth", "Number");
            entry.maxHeight = parseValue(datum, "maxHeight", "Number");
            break;
        }

        return entry;
    }

    /**
     * Get the filenames of all (normal) files currently stored in this pack
     * during editing.
     */
    public function getFilenames (includeContent :Boolean = false) :Array /* of String */
    {
        var names :Array = [];
        for each (var zipEntry :ZipEntry in _zip.entries) {
            names.push(zipEntry.name);
        }

        for (var name :String in _newFiles) {
            if (!ArrayUtil.contains(names, name)) {
                names.push(name);
            }
        }
        ArrayUtil.removeFirst(names, METADATA_FILENAME);
        if (!includeContent) {
            ArrayUtil.removeFirst(names, getFileName(CONTENT_DATANAME));
        }

        return names;
    }

    /**
     * Retrieve a file by the filename.
     */
    public function getFileByFilename (filename :String) :ByteArray
    {
        return getFileBytes(filename);
    }

    /**
     * Set a data value.
     */
    public function setData (name :String, value :*) :void
    {
        var cleanName :String = validateAccess(name);

        var datum :XML = getDatum(_metadata..data, cleanName);
        if (datum == null) {
            throw new Error("No such data name");
        }

        formatValue(datum, value);
        dispatchEvent(new ValueEvent(DATA_CHANGED, name));
    }

    /**
     * Replace a file.
     *
     * @param name the fieldName of the file to replace.
     * @param filename, can be used to point multiple fields at the same file,
     * or may be null to remove the file.
     * @param data the bytes associated with the specified filename.
     */
    public function replaceFile (name :String, filename :String, data :ByteArray = null) :void
    {
        var cleanName :String = validateAccess(name);

        var datum :XML = getDatum(_metadata..file, cleanName);
        if (datum == null) {
            throw new Error("No such file name");
        }

        if (filename == null) {
            delete datum.@value;

        } else {
            formatValue(datum, filename, "value", "String");
            if (data != null) {
                _newFiles[filename] = data;
            }
        }
        dispatchEvent(new ValueEvent(FILE_CHANGED, name));
    }

    protected function formatValue (
        datum :XML, value :*, valueField :String = "value", typeOverride :String = null) :void
    {
        if (value == null) {
            delete datum.@[valueField];
            return;
        }

        var type :String = (typeOverride != null) ? typeOverride : String(datum.@type);
        datum.@[valueField] = formatValueToString(value, type);
    }

    protected function formatValueToString (value :*, type :String) :String
    {
        switch (type) {
//        case "bareString":
//            return String(value);
//
        case "String":
        case "Choice":
            return escape(String(value));

        case "Number":
        case "int":
            return String(value);

        case "Boolean":
            return String(Boolean(value));

        case "Color":
            return uint(value).toString(16);

        case "Array":
            return value.map(function (item :String, ... rest) :String {
                return escape(item);
            }).join(",");

        case "Point":
            var p :Point = Point(value);
            return String(p.x) + "," + p.y;

        case "Rectangle":
            var r :Rectangle = Rectangle(value);
            return String(r.x) + "," + r.y + "," + r.width + "," + r.height;

        default:
            trace("Unknown resource type: " + type);
            return null;
        }
    }

    /**
     * Serialize this pack into a ByteArray suitable for saving.
     */
    public function serialize () :ByteArray
    {
        var outZip :ZipOutput = new ZipOutput();

        // let's write out the metadata first
        var entry :ZipEntry = new ZipEntry(METADATA_FILENAME);
        outZip.putNextEntry(entry);
        outZip.write(stringToBytes(XmlUtil.toXMLString(_metadata)));
        outZip.closeEntry();

        var seenFiles :Dictionary = new Dictionary();
        var names :Array = getFileFields(true);

        for each (var name :String in names) {
            var fileName :String = getFileName(name);
            if (fileName != null && !Boolean(seenFiles[fileName])) {
                entry = new ZipEntry(fileName);
                outZip.putNextEntry(entry);
                outZip.write(getFileBytes(fileName));
                outZip.closeEntry();
                seenFiles[fileName] = true;
            }
        }
        outZip.finish();

        return outZip.byteArray;
    }

    override protected function getFileBytes (fileName :String) :ByteArray
    {
        // see if we've got a new file by that name, which takes precedence over an old file
        var bytes :ByteArray = _newFiles[fileName] as ByteArray;
        if (bytes != null) {
            return bytes;

        } else {
            return super.getFileBytes(fileName);
        }
    }

    override protected function validateName (name :String) :void
    {
        switch (name) {
        case CONTENT_DATANAME: // this name is OK here
            break;

        default:
            super.validateName(name);
            break;
        }
    }

    protected function stringToBytes (s :String) :ByteArray
    {
        var ba :ByteArray = new ByteArray();
        ba.writeUTFBytes(s);
        return ba;
    }

//    /** Contains filenames that are in the _zip that should not be written.
//     * Maps: <filename>:String -> true */
//    protected var _omittedFiles :Object = {};

    /** New file data not contained in the _zip.
     * Maps: <filename>:String -> <data>:ByteArray */
    protected var _newFiles :Object = {};
}
}
