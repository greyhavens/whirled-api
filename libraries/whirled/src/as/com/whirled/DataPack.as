//
// $Id$

package com.whirled {

import flash.display.DisplayObject;

import flash.errors.IllegalOperationError;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

import flash.media.Sound;

import flash.utils.ByteArray;

import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Util;

import nochump.util.zip.ZipEntry;
import nochump.util.zip.ZipError;
import nochump.util.zip.ZipFile;

/**
 * Dispatched when the DataPack has completed loading.
 *
 * @eventType flash.events.Event.COMPLETE
 */
[Event(name="complete", type="flash.events.Event")]

/**
 * Dispatched when the DataPack could not load due to an error.
 *
 * @eventType flash.events.ErrorEvent.ERROR
 */
[Event(name="error", type="flash.events.ErrorEvent")]

/**
 * Handles downloading and extracting goodies from a DataPack.
 */
public class DataPack extends EventDispatcher
{
    /**
     * Construct a DataPack to be loaded from specified source.
     * Note that passing a ByteArray will result in a DataPack that is instantly complete.
     *
     * @param urlOrByteArray a url (as a String or as a URLRequest) from which to load the
     *        DataPack, or a ByteArray containing the raw data.
     *
     * @throws TypeError if urlOrByteArray is not of the right type.
     */
    public function DataPack (urlOrByteArray :*)
    {
        var req :URLRequest = null;
        var bytes :ByteArray;

        if (urlOrByteArray is String) {
            req = new URLRequest(String(urlOrByteArray)); // throw malformedURL asap

        } else if (urlOrByteArray is URLRequest) {
            req = URLRequest(urlOrByteArray);
            
        } else if (urlOrByteArray is ByteArray) {
            bytes = ByteArray(urlOrByteArray);

        } else {
            throw new TypeError("Expected a String or ByteArray");
        }

        if (req != null) {
            _loader = new URLLoader();
            _loader.dataFormat = URLLoaderDataFormat.BINARY;
            _loader.addEventListener(Event.COMPLETE, handleLoadingComplete);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleLoadError);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadError);
            _loader.load(req);

        } else {
            bytes.position = 0;
            bytesAvailable(bytes);
        }
    }

    /**
     * Stop loading a DataPack, if not yet complete. You should probably call this
     * during shutdown.
     */
    public function close () :void
    {
        if (_loader != null) {
            try {
                _loader.close();
            } catch (err :Error) {
                // ignore
            }
            _loader = null;
        }
    }

    /**
     * Has the loading of the datapack completed?
     */
    public function isComplete () :Boolean
    {
        return (_metadata != null);
    }

    /**
     * TODO
     * @private
     */
    public function getNamespace () :String
    {
        validateComplete();
        return unescape(String(_metadata.attribute("namespace")));
    }

    /**
     * Convenience function to access some data as a String.
     */
    public function getString (name :String) :String
    {
        return getData(name) as String;
    }

    /**
     * Convenience function to access some data as a Number.
     */
    public function getNumber (name :String) :Number
    {
        return getData(name) as Number;
    }

    /**
     * Convenience function to access some data as a Boolean.
     */
    public function getBoolean (name :String) :Boolean
    {
        return getData(name) as Boolean;
    }

    /**
     * Convenience function to access some data as a color (uint).
     */
    public function getColor (name :String) :uint
    {
        return getData(name) as uint;
    }

    /**
     * Convenience function to access some data as an Array.
     */
    public function getArray (name :String) :Array
    {
        return getData(name) as Array;
    }

    /**
     * Convenience function to access some data as a Point.
     */
    public function getPoint (name :String) :Point
    {
        return getData(name) as Point;
    }

    /**
     * Convenience function to access some data as a Rectangle.
     */
    public function getRectangle (name :String) :Rectangle
    {
        return getData(name) as Rectangle;
    }

    /**
     * Get some data.
     */
    public function getData (name :String) :*
    {
        name = validateAccess(name);

        var datum :XML = _metadata..data.(@name == name)[0];
        if (datum == null) {
            return undefined;
        }

        return parseValue(datum);
    }

    /**
     * Parse a data value from the specified XML datum.
     *
     * @private
     */
    protected function parseValue (
        datum :XML, valueField :String = "value", typeOverride :String = null) :*
    {
        var val :XMLList = datum.@[valueField];
        if (val.length == 0 || val[0] === undefined) {
            return undefined;
        }

        var value :String = String(val[0]);
//        trace("Raw " + valueField + " for data '" + name + "' is '" + value + "'");
        if (value == null) {
            return undefined;
        }
        var bits :Array;
        var type :String = (typeOverride != null) ? typeOverride : String(datum.@type);
        switch (type) {
        case "String":
            return unescape(value);

        case "Number":
            return parseFloat(value);

        case "Boolean":
            return "true" == value.toLowerCase();

        case "Color":
            return parseInt(value, 16);

        case "Array":
            return value.split(",").map(function (item :String, ... rest) :String {
                return unescape(item);
            });

        case "Point":
            bits = value.split(",");
            return new Point(parseFloat(bits[0]), parseFloat(bits[1]));

        case "Rectangle":
            bits = value.split(",");
            return new Rectangle(parseFloat(bits[0]), parseFloat(bits[1]),
                parseFloat(bits[2]), parseFloat(bits[3]));

        default:
            trace("Unknown resource type: " + type);
            return value;
        }
    }

    /**
     * Get a File, as a ByteArray.
     */
    public function getFile (name :String) :ByteArray
    {
        return getFileInternal(name, false) as ByteArray;
    }

    /**
     * Get a File, as a String.
     */
    public function getFileAsString (name :String) :String
    {
        return getFileInternal(name, true) as String;
    }

    /**
     * Get a File, as an XML object.
     */
    public function getFileAsXML (name :String) :XML
    {
        return Util.newXML(getFileAsString(name));
    }
    
    /**
     * Get sounds. TODO. This is not quite ready for primetime.
     * @private
     */
    public function getSounds (names :Array, callback :Function) :void
    {
        var fn :Function = function (obj :Object) :void {
            var newObj :Object = {};

            for (var s :String in obj) {
                var o :Object = obj[s];
                try {
                    o = o["getSound"]();
                } catch (err :Error) {
                    trace("Error getSound: " + err);
                }
                newObj[s] = (o as Sound);
            }

            callback(newObj);
        };

        getDisplayObjects(names, fn);
    }

    /**
     * Get some display objects in the datapack.
     *
     * @param names an Array of the names of the display objects to load.
     * @param callback a Function that will be called when all the display objects
     *                 are loaded (or were unable to load).
     *                 Signature: <code>function (results :Object) :void</code>
     *                 results will contain a mapping from name -> DisplayObject, or null if none.
     * @param useSubDomain if true, classes in a loaded SWF will be added to an
     *                     ApplicationDomain that is a child of the current ApplicationDomain.
     */
    public function getDisplayObjects (
        names :Array, callback :Function, useSubDomain :Boolean = false) :void
    {
        doGetObjects(names, callback, useSubDomain, false);
    }

    /**
     * Get SWF loaders for each SWF in the datapack.
     *
     * @param names an Array of the names of the display objects to load.
     * @param callback a Function that will be called when all the display objects
     *                 are loaded (or were unable to load).
     *                 Signature: <code>function (results :Object) :void</code>.
     *                 results will contain a mapping from name -> EmbeddedSwfLoader, or null.
     * @param useSubDomain if true, classes in a loaded SWF will be added to an
     *                     ApplicationDomain that is a child of the current ApplicationDomain.
     */
    public function getSwfLoaders (
        names :Array, callback :Function, useSubDomain :Boolean = false) :void
    {
        doGetObjects(names, callback, useSubDomain, true);
    }

    /**
     * Start the asynchronous loading of files from within the DataPack.
     *
     * @private
     */
    protected function doGetObjects (
        names :Array, callback :Function, useSubDomain :Boolean, returnRawLoaders :Boolean) :void
    {
        // our eventual return value
        var dispObjects :Object = {};
        var fileName :String;

        // first, go through and extract the ByteArray for each file,
        // which will also verify the names
        for each (fileName in names) {
            // if a name shows up twice in the list, we only load it once...
            if (!(fileName in dispObjects)) {
                dispObjects[fileName] = getFile(fileName);
            }
        }

        var loaded :int = 0;
        var toLoad :int = 0;
        var loadHandler :Function = function (name :String, result :Object) :void {
            // store the result of the load
            dispObjects[name] = result;

            // see if it's time to call the callback
            if (++loaded == toLoad) {
                callback(dispObjects);
            }
        };

        // now actually load all the ByteArrays we successfully found
        for (fileName in dispObjects) {
            var bytes :ByteArray = dispObjects[fileName] as ByteArray;
            if (bytes != null) {
                toLoad++;
                doLoadObject(fileName, bytes, loadHandler, useSubDomain, returnRawLoaders);
            }
        }

        // finally, if by some reason there's nothing to load, succeed now
        if (toLoad == 0) {
            callback(dispObjects);
        }
    }

    /**
     * Load one file up with an EmbeddedSwfLoader.
     *
     * @private
     */
    protected function doLoadObject (
        name :String, bytes :ByteArray, loadHandler :Function,
        useSubDomain :Boolean, returnRawLoaders :Boolean) :void
    {
        var esl :EmbeddedSwfLoader = new EmbeddedSwfLoader(useSubDomain);

        var eslHandler :Function = function (event :Event) :void {
            if (event.type == Event.COMPLETE) {
                loadHandler(name, returnRawLoaders ? esl : esl.getContent());
            } else {
                loadHandler(name, null);
            }
        }

        esl.addEventListener(Event.COMPLETE, eslHandler);
        esl.addEventListener(IOErrorEvent.IO_ERROR, eslHandler);

        esl.load(bytes);
    }

    /**
     * Locate the data contained within a file with the specified data name.
     *
     * @private
     */
    protected function getFileInternal (name :String, asString :Boolean) :*
    {
        var value :String = getFileName(name);
        if (value == null) {
            return undefined;
        }

        var bytes :ByteArray = getFileBytes(value);
        if (asString && bytes != null) {
            return bytesToString(bytes);

        } else {
            return bytes;
        }
    }

    /**
     * Get the actual bytes in use for the specified filename.
     *
     * @private
     */
    protected function getFileBytes (fileName :String) :ByteArray
    {
        var entry :ZipEntry = _zip.getEntry(fileName);
        if (entry == null) {
            return null;
        }
        return _zip.getInput(entry);
    }

    /**
     * Translate the requested file into the actual filename stored in the zip.
     *
     * @private
     */
    protected function getFileName (name :String) :String
    {
        name = validateAccess(name);

        var datum :XML = _metadata..file.(@name == name)[0];
        if (datum == null) {
            return null;
        }

        return parseValue(datum, "value", "String");
    }

    /**
     * Validate that the everything is ok accessing the specified data name.
     *
     * @private
     */
    protected function validateAccess (name :String) :String
    {
        validateComplete();
        validateName(name);

        // TODO: we may need to verify that the urlencoding is happening the same
        // way that it is in Java
        return escape(name);
    }

    /**
     * Validate that this DataPack has completed loading.
     *
     * @private
     */
    protected function validateComplete () :void
    {
        if (!isComplete()) {
            throw new IllegalOperationError("DataPack is not loaded.");
        }
    }

    /**
     * Validate that the specified data name is legal.
     *
     * @private
     */
    protected function validateName (name :String) :void
    {
        switch (name) {
        case null: // names can't be null
        case CONTENT_DATANAME: // reserved for special all-in-one media
            throw new ArgumentError("Invalid name: " + name);
        }
    }

    /**
     * Handle some sort of problem loading the datapack.
     *
     * @private
     */
    protected function handleLoadError (event :ErrorEvent) :void
    {
        close();
        dispatchError("Error loading datapack: " + event.text);
    }

    /**
     * Handle the successful completion of datapack loading.
     *
     * @private
     */
    protected function handleLoadingComplete (event :Event) :void
    {
        var ba :ByteArray = ByteArray(_loader.data);
        _loader = null;
        bytesAvailable(ba);
    }

    /**
     * Read the zip file.
     *
     * @private
     */
    protected function bytesAvailable (bytes :ByteArray) :void
    {
        try {
            _zip = new ZipFile(bytes);
        } catch (zipError :ZipError) {
            dispatchError("Unable to read datapack: " + zipError.message);
            return;
        }

        var dataFile :ZipEntry = _zip.getEntry(METADATA_FILENAME);
        if (dataFile == null) {
            dispatchError("No " + METADATA_FILENAME + " contained in DataPack.");
            return;
        }

        var asString :String = bytesToString(_zip.getInput(dataFile));

        // now try parsing the data
        try {
            // this also can throw an Error if the XML doesn't parse
            _metadata = Util.newXML(asString);

        } catch (error :Error) {
            dispatchError("Could not parse datapack: " + error.message);
            return;
        }

        // yay, we're completely loaded!
        dispatchEvent(new Event(Event.COMPLETE));
    }

    /**
     * Turn the specified ByteArray into a String.
     *
     * @private
     */
    protected function bytesToString (ba :ByteArray) :String
    {
        ba.position = 0;
        return ba.readUTFBytes(ba.bytesAvailable);
    }

    /**
     * Dispatch an error event with the specified message.
     *
     * @private
     */
    protected function dispatchError (message :String) :void
    {
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
    }

    /** Used only while loading the zip bytes. @private */
    protected var _loader :URLLoader;

    /** The contents of the datapack. @private */
    protected var _zip :ZipFile;

    /** The metadata. @private */
    protected var _metadata :XML;

    /** The filename of the metadata file. @private */
    protected static const METADATA_FILENAME :String = "_data.xml";

    /** The data name of the primary media file, used for all-in-one remixable media. @private */
    protected static const CONTENT_DATANAME :String = "_CONTENT";
}
}