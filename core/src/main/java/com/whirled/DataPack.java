package com.whirled;

import java.awt.Color;

import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

import java.awt.image.BufferedImage;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;

import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

import java.util.HashMap;
import java.util.Map;
import java.util.LinkedHashMap;

import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import javax.imageio.ImageIO;

import org.apache.commons.digester.Digester;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

import com.samskivert.util.ResultListener;
import com.samskivert.util.StringUtil;

import com.samskivert.xml.SetPropertyFieldsRule;

// TODO: double check encodings, as stringing numbers using the locale may inject commas
public class DataPack
{
    public DataPack (final String url, final ResultListener<DataPack> listener)
    {
        Thread tt = new Thread() {
            public void run () {
                try {
                    URL u = new URL(url);
                    URLConnection conn = u.openConnection();
                    DataPack.this.init(conn.getInputStream());

                } catch (MalformedURLException mue) {
                    listener.requestFailed(mue);
                    return;

                } catch (IOException ioe) {
                    listener.requestFailed(ioe);
                    return;
                }

                // finally, ensure we ever got _data.xml
                if (_metadata != null) {
                    listener.requestCompleted(DataPack.this);

                } else {
                    listener.requestFailed(new Exception("No " + METADATA_FILENAME +
                        " contained in DataPack."));
                }
            }
        };

        tt.start();
    }

    protected DataPack ()
    {
    }

    /**
     * Stop loading a DataPack, if not yet complete. Call this if you need to shutdown.
     */
    public void close ()
    {
        _closed = true;
    }

    /**
     * Has the loading of the datapack completed?
     */
    public boolean isComplete ()
    {
        return !_closed && (_metadata != null);
    }

    /**
     * Get the namespace of this data pack.
     */
    // TODO: sort out what this means
    public String getNamespace ()
    {
        validateComplete();
        return _metadata.namespace;
    }

    /**
     * Convenience method to access some data as a String.
     */
    public String getString (String name)
    {
        return (String) getData(name);
    }

    /**
     * Convenience method to access some data as a Number (Double).
     */
    public Double getNumber (String name)
    {
        return (Double) getData(name);
    }

    /**
     * Convenience method to access some data as a Boolean.
     */
    public Boolean getBoolean (String name)
    {
        return (Boolean) getData(name);
    }

    /**
     * Convenience method to access some data as a Color.
     */
    public Color getColor (String name)
    {
        return (Color) getData(name);
    }

    /**
     * Convenience method to access some data as an array.
     */
    public String[] getArray (String name)
    {
        return (String[]) getData(name);
    }

    /**
     * Convenience method to access some data as a Point.
     */
    public Point2D.Double getPoint (String name)
    {
        return (Point2D.Double) getData(name);
    }

    /**
     * Convenience method to access some data as a Rectangle.
     */
    public Rectangle2D.Double getRectangle (String name)
    {
        return (Rectangle2D.Double) getData(name);
    }

    /**
     * Get some data.
     */
    public Object getData (String name)
    {
        name = validateAccess(name);
        DataEntry entry = _metadata.datas.get(name);
        return (entry == null) ? null : entry.value;
    }

    /**
     * Get a File as a byte[].
     */
    public byte[] getFile (String name)
    {
        return (byte[]) getFile(name, false);
    }

    /**
     * Get a File as a String.
     */
    public String getFileAsString (String name)
    {
        return (String) getFile(name, true);
    }

    /**
     * Convenience method to get a File as an Image.
     */
    public BufferedImage getImage (String name)
    {
        byte[] data = getFile(name);
        if (data == null) {
            return null;
        }
        try {
            return ImageIO.read(new ByteArrayInputStream(data));

        } catch (IOException ioe) {
            System.err.println("Not possible: " + ioe);
            return null;
        }
    }

    protected Object getFile (String name, boolean asString)
    {
        name = validateAccess(name);

        FileEntry entry = _metadata.files.get(name);
        if (entry == null) {
            return null;
        }

        String value = (String) entry.value;
        if (value == null) {
            return null;
        }

        byte[] data = _files.get(value);
        if (data != null && asString) {
            try {
                return new String(data, "utf-8");

            } catch (UnsupportedEncodingException uee) {
                // what? No utf-8?
                return new String(data);
            }
        }
        return data;
    }

    protected String validateAccess (String name)
    {
        validateComplete();
        validateName(name);

        return name; // here on the Java side, the names are already decoded in _metadata.
    }

    protected void validateComplete ()
    {
        if (!isComplete()) {
            throw new IllegalStateException("DataPack is not loaded.");
        }
    }

    protected void validateName (String name)
    {
        if (name == null || CONTENT_DATANAME.equals(name)) {
            throw new IllegalArgumentException("Invalid name: " + name);
        }
    }

    /**
     * Parse and initialize the DataPack.
     */
    protected void init (InputStream ins)
        throws IOException
    {
        MetaData metadata = null;

        ZipInputStream zis = new ZipInputStream(ins);
        ZipEntry entry;
        while (!_closed && null != (entry = zis.getNextEntry())) {
            String name = entry.getName();
            byte[] data = new byte[(int) entry.getSize()];

            int offset = 0;
            int read = 0;
            while (!_closed && read != -1 && offset != data.length) {
                read = zis.read(data, offset, data.length - offset);
                offset += read;
            }

            if (METADATA_FILENAME.equals(name)) {
                metadata = parseMetaData(data);

            } else {
                _files.put(name, data);
            }
        }

        // only after we've had success parsing everything do we accept the metadata
        _metadata = metadata;
        didInit();
    }

    protected MetaData parseMetaData (byte[] data)
        throws IOException
    {
        // a field parser we can use for any String fields that need decoding.
        final SetPropertyFieldsRule.FieldParser decodeParser =
            new SetPropertyFieldsRule.FieldParser() {
                public Object parse (String property)
                    throws Exception
                {
                    return StringUtil.decode(property);
                }
            };

        Digester digester = new Digester();
        digester.addObjectCreate("datapack", MetaData.class);
        SetPropertyFieldsRule mainParser = new SetPropertyFieldsRule();
        mainParser.addFieldParser("namespace", decodeParser);
        digester.addRule("datapack", mainParser);

        digester.addRule("datapack/data", new SetPropertyFieldsRule() {
            { // initializer
                addFieldParser("type", new FieldParser() {
                    public Object parse (String property)
                        throws Exception
                    {
                        return DataType.parseType(property);
                    }
                });
                addFieldParser("name", decodeParser);
                addFieldParser("info", decodeParser);

                // We need to have a non-modifying parser just to massage the String -> Object
                // (Which doesn't really need massaging, but otherwise the ValueMarshaller bitches)
                // We take care of actually parsing the value once we're sure we know the type,
                // in the end() method, below.
                FieldParser massager = new FieldParser() {
                    public Object parse (String property)
                        throws Exception
                    {
                        return property;
                    }
                };
                addFieldParser("value", massager);
                addFieldParser("defaultValue", massager);
            }

            public void begin (String namespace, String name, Attributes attrs)
                throws Exception
            {
                digester.push(new DataEntry());
                super.begin(namespace, name, attrs);
            }

            public void end (String namespace, String name)
                throws Exception
            {
                DataEntry entry = (DataEntry) digester.pop();
                MetaData metadata = (MetaData) digester.peek();
                // parse the actual values now that we know the type
                entry.value = entry.type.parseValue((String) entry.value);
                entry.defaultValue = entry.type.parseValue((String) entry.defaultValue);
                // and store it
                metadata.datas.put(entry.name, entry);
            }
        });
        digester.addRule("datapack/file", new SetPropertyFieldsRule() {
            { // initializer
                addFieldParser("type", new FieldParser() {
                    public Object parse (String property)
                        throws Exception
                    {
                        return FileType.parseType(property);
                    }
                });
                addFieldParser("name", decodeParser);
                addFieldParser("info", decodeParser);
                addFieldParser("value", decodeParser);
            }

            public void begin (String namespace, String name, Attributes attrs)
                throws Exception
            {
                digester.push(new FileEntry());
                super.begin(namespace, name, attrs);
            }

            public void end (String namespace, String name)
                throws Exception
            {
                FileEntry entry = (FileEntry) digester.pop();
                MetaData metadata = (MetaData) digester.peek();
                metadata.files.put(entry.name, entry);
            }
        });

        try {
            return (MetaData) digester.parse(new ByteArrayInputStream(data));
        } catch (SAXException saxe) {
            throw (IOException) new IOException().initCause(saxe);
        }
    }

    /**
     * A place for subclasses to do something after initialization.
     */
    protected void didInit ()
    {
        // nothing right now, but please call super()
    }

    /**
     * Implemented by DataType nad FileType to simplify a few things.
     */
    public static interface AbstractType
    {
        // from Object
        public String toString ();

        /**
         * Get a human-readable description of this type.
         */
        public String getDescription ();

        /**
         * Format the value for writing back out.
         */
        public String formatValue (Object value);
    }

    public enum DataType
        implements AbstractType
    {
        /** If we're parsing a DataPack created with newer code, there may be data types
         * we don't understand. They'll be assigned this type. */
        UNKNOWN_TYPE(null, null),

        /** A String. */
        STRING("String", "Any string"),

        /** A floating point number. */
        NUMBER("Number", "Floating point number"),

        /** A boolean value. */
        BOOLEAN("Boolean", "A value of true or false"),

        /** A color value. */
        COLOR("Color", "An RGB color value"),

        /** An untyped array. */
        ARRAY("Array", "An array of strings"),

        /** Two floating point values representing x and y. */
        POINT("Point", "A 2-dimensional floating point coordinate"),

        /** Four floating point values representing x, y, width, and height. */
        RECTANGLE("Rectangle", "A 2-dimension floating point coordinate, plus width and height"),

        ; // End of enums

        /**
         * Constructor.
         */
        private DataType (String strName, String desc)
        {
            _strName = strName;
            _desc = desc;
        }

        public String toString ()
        {
            return _strName;
        }

        // from AbstractType
        public String getDescription ()
        {
            return _desc;
        }

        // from AbstractType
        public String formatValue (Object value)
        {
            if (value == null) {
                return null;
            }

            switch (this) {
            case STRING:
                return StringUtil.encode((String) value);

            case NUMBER:
                return StringUtil.encode(String.valueOf(value));

            case BOOLEAN:
                return String.valueOf(value);

            case COLOR:
                {
                    Color c = (Color) value;
                    // printf is 1.5, and a slight pain
                    return formatColorComponent(c.getRed()) + formatColorComponent(c.getGreen()) +
                        formatColorComponent(c.getBlue());
                }

            case ARRAY:
                String[] arr = (String[]) value;
                StringBuilder buf = new StringBuilder();
                for (int ii = 0; ii < arr.length; ii++) {
                    if (ii > 0) {
                        buf.append(',');
                    }
                    buf.append(StringUtil.encode(arr[ii]));
                }
                return buf.toString();

            case POINT:
                Point2D.Double pt = (Point2D.Double) value;
                return String.valueOf(pt.getX()) + "," + String.valueOf(pt.getY());

            case RECTANGLE:
                Rectangle2D.Double rec = (Rectangle2D.Double) value;
                return String.valueOf(rec.getX()) + "," + String.valueOf(rec.getY()) + "," +
                    String.valueOf(rec.getWidth()) + "," + String.valueOf(rec.getHeight());

            default:
                throw new RuntimeException("Cannot write a datapack containing a type value we " +
                    "do not understand! [type=" + this + "].");
            }
        }

        /**
         * Parse the String value into an object.
         *
         * This could have been done with a value-specific method implementation, but
         * it's actually easier to just do a switch statement...
         */
        public Object parseValue (String value)
        {
            return parseValue(value, false);
        }

        /**
         * Parse the String value into an Object, choosing to throw a RuntimeException
         * if there's trouble.
         */
        public Object parseValue (String value, boolean throwRuntimeExceptions)
        {
            if (value == null) {
                // TODO: accept this? We may not want to.
                return null;
            }

            switch (this) {
            case STRING:
                return StringUtil.decode(value);

            case NUMBER:
            {
                try {
                    return new Double(StringUtil.decode(value));

                } catch (NumberFormatException nfe) {
                    if (throwRuntimeExceptions) {
                        throw new RuntimeException(nfe);
                    }
                    return Double.valueOf(Double.NaN);
                }
            }

            case BOOLEAN:
                return Boolean.valueOf("true".equals(value.toLowerCase()));

            case COLOR:
            {
                try {
                    return new Color(Integer.parseInt(value, 16));
                } catch (NumberFormatException nfe) {
                    if (throwRuntimeExceptions) {
                        throw new RuntimeException(nfe);
                    }
                    return Color.WHITE;
                }
            }

            case ARRAY:
            {
                // StringUtil.parseStringArray doesn't do things the way we'd like...
                String[] array = value.split(",");
                for (int ii = 0; ii < array.length; ii++) {
                    array[ii] = StringUtil.decode(array[ii]);
                }
                return array;
            }

            case POINT:
            {
                String[] bits = value.split(",");
                if (bits.length != 2 && throwRuntimeExceptions) {
                    throw new RuntimeException("Points must be made of two numbers.");
                }
                try {
                    return new Point2D.Double(
                        Double.parseDouble(bits[0]), Double.parseDouble(bits[1]));

                } catch (NumberFormatException nfe) {
                    if (throwRuntimeExceptions) {
                        throw new RuntimeException(nfe);
                    }
                    return new Point2D.Double();
                }
            }

            case RECTANGLE:
            {
                String[] bits = value.split(",");
                if (bits.length != 4 && throwRuntimeExceptions) {
                    throw new RuntimeException("Rectangles must be made of four numbers.");
                }
                try {
                    return new Rectangle2D.Double(
                        Double.parseDouble(bits[0]), Double.parseDouble(bits[1]),
                        Double.parseDouble(bits[2]), Double.parseDouble(bits[3]));

                } catch (NumberFormatException nfe) {
                    if (throwRuntimeExceptions) {
                        throw new RuntimeException(nfe);
                    }
                    return new Rectangle2D.Double();
                }
            }

            case UNKNOWN_TYPE:
                return StringUtil.decode(value);

            default:
                throw new RuntimeException("Unimplemented parseValue for " + this);
            }
        }

        public static DataType parseType (String typeStr)
        {
            // this doesn't need to be super fast
            for (DataType dt : values()) {
                if (typeStr.equals(dt.toString())) {
                    return dt;
                }
            }

            System.err.println("Unknown data type: " + typeStr);
            return UNKNOWN_TYPE;
        }

        /**
         * Format an RGB color component (with a value from 0 - 255) into a 2-digit hex string.
         */
        protected static String formatColorComponent (int value)
        {
            String s = Integer.toHexString(value);
            if (s.length() < 2) {
                s = "0" + s;
            }
            return s;
        }

        /** The String name of this type. */
        protected String _strName;

        /** A human-readable description of the data type. */
        protected String _desc;

    } // END: enum DataType

    public enum FileType
        implements AbstractType
    {
        /** If we're parsing a DataPack created with newer code, there may be file types
         * we don't understand. They'll be assigned this type. */
        UNKNOWN_TYPE(null, null, null),

        /** An image type: png, gif, or jpg only. */
        IMAGE("Image", "gif, jpg, or png only", new String[] {"gif", "jpg", "jpeg", "png" }),

        /** Image + SWF. */
        DISPLAY_OBJECT("DisplayObject", "gif, jpg, png, or swf",
            new String[] { "gif", "jpg", "jpeg", "png", "swf" }),

        /** An au file. */
        JAVA_SOUND("JavaSound", "An .au sound file", new String[] { "au" }),

        /** An mp3 wrapped in a SWF. */
        FLASH_SOUND("FlashSound", "An .mp3 sound file", new String[] { "mp3" }),

        /** Whatever. Bare binary data. */
        BLOB("Blob", "Any file", null),

        ; // End of enums

        /**
         * Constructor.
         */
        private FileType (String strName, String desc, String[] extensions)
        {
            _strName = strName;
            _desc = desc;
            _extensions = extensions;
        }

        public String toString ()
        {
            return _strName;
        }

        // from AbstractType
        public String getDescription ()
        {
            return _desc;
        }

        // from AbstractType
        public String formatValue (Object value)
        {
            // we merely need to re-encode the filename
            return StringUtil.encode((String) value);
        }

        /**
         * Return the filename extensions acceptable for this type, or null for any.
         */
        public String[] getExtensions ()
        {
            return _extensions;
        }

        public static FileType parseType (String typeStr)
        {
            // this doesn't need to be super fast
            for (FileType ft : values()) {
                if (typeStr.equals(ft.toString())) {
                    return ft;
                }
            }

            System.err.println("Unknown file type: " + typeStr);
            return UNKNOWN_TYPE;
        }

        /** The String name of this type. */
        protected String _strName;

        /** The description of this type. */
        protected String _desc;

        /** The valid file extensions for this type. */
        protected String[] _extensions;

    } // END: enum FileType

    public static abstract class AbstractEntry
    {
        /** The name of the data. */
        public String name;

        /** A human-readable description. */
        public String info = "";

        /** The value, or null if none. */
        public Object value;

        /** Is this value optional? */
        public boolean optional;

        public abstract AbstractType getType ();

        /**
         * Output the attributes as XML.
         */
        protected void attrsToXML (StringBuilder buf)
        {
            AbstractType type = getType();
            buf.append(" name=\"").append(StringUtil.encode(name)).append("\"");
            buf.append(" type=\"").append(type).append("\"");
            if (value != null) {
                buf.append(" value=\"").append(type.formatValue(value)).append("\"");
            }
            if (!StringUtil.isBlank(info)) {
                buf.append(" info=\"").append(StringUtil.encode(info)).append("\"");
            }
            if (optional) {
                buf.append(" optional=\"true\"");
            }
        }
    } // END: class AbstractEntry
    
    /** MetaData entry describing data. */
    public static class DataEntry extends AbstractEntry
    {
        /** The type of the data. */
        public DataType type;

        /** A default value. */
        // TODO: currently unused
        public Object defaultValue;

        public DataEntry ()
        {
        }

        // from AbstractEntry
        public AbstractType getType ()
        {
            return type;
        }

        /**
         * Convert this entry to XML.
         */
        public String toXML ()
        {
            StringBuilder buf = new StringBuilder("<data");
            attrsToXML(buf);
            buf.append("/>");
            return buf.toString();
        }

        @Override
        protected void attrsToXML (StringBuilder buf)
        {
            super.attrsToXML(buf);
            if (defaultValue != null) {
                buf.append(" defaultValue=\"").append(type.formatValue(defaultValue)).append("\"");
            }
        }

    } // END: class DataEntry

    /** MetaData entry describing a file. */
    public static class FileEntry extends AbstractEntry
    {
        /** The type of the file. */
        public FileType type;

        public FileEntry ()
        {
        }

        // from AbstractEntry
        public AbstractType getType ()
        {
            return type;
        }

        /**
         * Convert this entry to XML.
         */
        public String toXML ()
        {
            StringBuilder buf = new StringBuilder("<file");
            attrsToXML(buf);
            buf.append("/>");
            return buf.toString();
        }
    } // END: class FileEntry

    /** MetaData holder class. */
    protected static class MetaData
    {
        /** The version of the datapack when we write one out (in our subclass).
         * This can be incremented should things change drastically,
         * but the intention is that older code can read newer packs and mostly cope. */
        public static final int CURRENT_VERSION = 1;

        /** The namespace of this DataPack. */
        public String namespace;

        /** The version of the metadata that was read in. This value is not currently consulted. */
        public int version;

        public MetaData () { }

        /** Data entries. */
        public Map<String, DataEntry> datas = new LinkedHashMap<String, DataEntry>();

        /** File entries. */
        public Map<String, FileEntry> files = new LinkedHashMap<String, FileEntry>();

        /**
         * Convert this metadata to XML.
         */
        public String toXML ()
        {
            StringBuilder buf = new StringBuilder("<datapack");
            buf.append(" version=\"").append(CURRENT_VERSION).append("\"");
            attrsToXML(buf);
            buf.append(">\n");
            childrenToXML(buf);
            buf.append("</datapack>");
            buf.append('\n'); // output a nice trailing newline
            return buf.toString();
        }

        protected void attrsToXML (StringBuilder buf)
        {
            if (namespace != null) {
                buf.append(" namespace=\"").append(StringUtil.encode(namespace)).append("\"");
            }
        }

        protected void childrenToXML (StringBuilder buf)
        {
            for (DataEntry entry : datas.values()) {
                buf.append('\t').append(entry.toXML()).append('\n');
            }
            for (FileEntry entry : files.values()) {
                buf.append('\t').append(entry.toXML()).append('\n');
            }
        }
    } // END: class MetaData

    /** The parsed metadata. */
    protected MetaData _metadata;

    /** Indicates when we've been closed early. */
    protected boolean _closed;

    /** File entries that present in the datapack. */
    protected HashMap<String,byte[]> _files = new HashMap<String,byte[]>();

    /** The filename of the metadata file. */
    protected static final String METADATA_FILENAME = "_data.xml";

    /** The data name of the primary media file, used for all-in-one remixable media. */
    protected static final String CONTENT_DATANAME = "_CONTENT";
}
