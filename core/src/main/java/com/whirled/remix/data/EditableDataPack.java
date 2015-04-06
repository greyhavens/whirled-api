//
// $Id$

package com.whirled.remix.data;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import java.util.HashSet;
import java.util.List;

import java.util.zip.CRC32;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import com.google.common.collect.Lists;

import com.samskivert.util.ObserverList;
import com.samskivert.util.ResultListener;
import com.samskivert.util.StringUtil;

import com.whirled.DataPack;

/**
 *
 */
public class EditableDataPack extends DataPack
{
    /**
     * Create a brand-new datapack.
     */
    public EditableDataPack ()
    {
        _metadata = new MetaData();
        didInit();
    }

    /**
     * Load the DataPack at the specified url for remixing.
     */
    public EditableDataPack (String url, final ResultListener<EditableDataPack> listener)
    {
        super(url, new ResultListener<com.whirled.DataPack>() {
            public void requestCompleted (DataPack pack) {
                // cast to this subclass
                listener.requestCompleted((EditableDataPack) pack);
            }

            public void requestFailed (Exception cause) {
                listener.requestFailed(cause);
            }
        });
    }

    /**
     * Add the specified change listener.
     */
    public void addChangeListener (ChangeListener listener)
    {
        _listeners.add(listener);
    }

    /**
     * Remove the specified change listener.
     */
    public void removeChangeListener (ChangeListener listener)
    {
        _listeners.remove(listener);
    }

    /**
     * Get a list of all the data fields.
     */
    public List<String> getDataFields ()
    {
        validateComplete();
        return Lists.newArrayList(_metadata.datas.keySet());
    }

    /**
     * Get a list of all the file fields.
     */
    public List<String> getFileFields ()
    {
        return getFileFields(false);
    }

    /**
     * Get a list of all the file fields, optionally excluding the _CONTENT.
     */
    public List<String> getFileFields (boolean includeContent)
    {
        validateComplete();

        List<String> result = Lists.newArrayList(_metadata.files.keySet());
        if (!includeContent) {
            result.remove(CONTENT_DATANAME);
        }
        return result;
    }

    /**
     * Get the DataEntry for the specified name, for direct editing. Don't fuck up!
     */
    public DataEntry getDataEntry (String name)
    {
        name = validateAccess(name);
        return _metadata.datas.get(name);
    }

    /**
     * Get the FileEntry for the specified name.
     */
    public FileEntry getFileEntry (String name)
    {
        name = validateAccess(name);
        return _metadata.files.get(name);
    }

    /**
     * Add a data parameter.
     */
    public void addDataEntry (String name, DataType type, String desc)
    {
        DataEntry entry = new DataEntry();
        entry.name = name;
        entry.type = type;
        entry.info = desc;

        _metadata.datas.put(name, entry);
        fireChanged();
    }

    /**
     * Add a file parameter.
     */
    public void addFileEntry (String name, FileType type, String description)
    {
        FileEntry entry = new FileEntry();
        entry.name = name;
        entry.type = type;
        entry.info = description;

        _metadata.files.put(name, entry);
        fireChanged();
    }

    /**
     * Remove the data entry with the specified name.
     */
    public void removeDataEntry (String name)
    {
        name = validateAccess(name);
        if (null != _metadata.datas.remove(name)) {
            fireChanged();
        }
    }

    /**
     * Remove the file entry with the specified name.
     */
    public void removeFileEntry (String name)
    {
        name = validateAccess(name);
        if (null != _metadata.files.remove(name)) {
            fireChanged();
        }
    }

    /**
     * Change the contents of a file.
     */
    public void replaceFile (String name, String filename, byte[] data)
    {
        name = validateAccess(name);
        FileEntry entry = _metadata.files.get(name);
        if (entry == null) {
            throw new IllegalArgumentException("No file named " + name);
        }

        entry.value = filename;

        // TODO: cope with clobbering an existing filename?
        _files.put(filename, data);
    }

    /**
     * Serialize this DataPack back into a ByteArray.
     */
    public byte[] toByteArray ()
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try {
            writeTo(baos);
        } catch (IOException ioe) {
            // this'll never happen with a ByteArrayOutputStream
            throw new RuntimeException(ioe);
        }
        return baos.toByteArray();
    }

    /**
     * Add a new file to this DataPack.
     */
    protected void addFile (
        String filename, byte[] data, String name, FileType type, String desc, boolean optional)
    {
        _files.put(filename, data);

        FileEntry entry = new FileEntry();
        entry.name = name;
        entry.type = type;
        entry.value = filename;
        entry.info = desc;
        entry.optional = optional;

        _metadata.files.put(name, entry);
        fireChanged();
    }

    /**
     * Write the DataPack to the specified stream.
     */
    protected void writeTo (OutputStream out)
        throws IOException
    {
        ZipOutputStream zos = new ZipOutputStream(out);
        zos.setMethod(ZipOutputStream.STORED);
        CRC32 crc = new CRC32();

        // TODO: If we put (an) Adler32 checksum(s) *somewhere* in here, then flash can read
        // entries that are DEFLATED. However, I don't at this time know how or where this
        // checksum is to be injected. If we figure it out in the future we can start compressing
        // the data. Note that this is irrelevant for the common media types: png, gif, jpg, swf,
        // and mp3 are all already compressed and are best simply STORED.

        // make a list of the filenames to actually save
        HashSet<String> filenames = new HashSet<String>();
        for (FileEntry entry : _metadata.files.values()) {
            String filename = (String) entry.value;
            if (!StringUtil.isBlank(filename)) {
                filenames.add(filename);
            }
        }
        // save those files into the zip
        for (String filename : filenames) {
            byte[] data = _files.get(filename);
            System.out.println("Storing '" + filename + "' (" + data.length + " bytes)");
            ZipEntry entry = new ZipEntry(filename);
            entry.setSize(data.length);
            crc.reset();
            crc.update(data);
            entry.setCrc(crc.getValue());
            zos.putNextEntry(entry);
            zos.write(data, 0, data.length);
            zos.closeEntry();
        }

        // write the metadata
        String metaXML = _metadata.toXML();
        byte[] data = metaXML.getBytes("utf-8");
        System.out.println("Storing '" + METADATA_FILENAME + "' (" + data.length + " bytes):");
        System.out.println(metaXML);
        ZipEntry entry = new ZipEntry(METADATA_FILENAME);
        entry.setSize(data.length);
        crc.reset();
        crc.update(data);
        entry.setCrc(crc.getValue());
        zos.putNextEntry(entry);
        zos.write(data, 0, data.length);
        zos.closeEntry();

        zos.finish();
    }

    /**
     * Fire a ChangeEvent to all our listeners.
     */
    protected void fireChanged ()
    {
        final ChangeEvent event = new ChangeEvent(this);

        _listeners.apply(new ObserverList.ObserverOp<ChangeListener>() {
            public boolean apply (ChangeListener listener) {
                listener.stateChanged(event);
                return true;
            }
        });
    }

    @Override
    protected void validateName (String name)
    {
        // let CONTENT_DATANAME pass here.
        if (!CONTENT_DATANAME.equals(name)) {
            super.validateName(name);
        }
    }

    /** Hold change listeners. */
    protected ObserverList<ChangeListener> _listeners =
        new ObserverList<ChangeListener>(ObserverList.FAST_UNSAFE_NOTIFY);
}
