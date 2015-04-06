//
// $Id$

package com.whirled.remix.data;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import java.util.Arrays;
import java.util.Map;

import com.samskivert.util.ResultListener;

/**
 *
 */
public class CreatingDataPack extends EditableDataPack
{
    /**
     * Create a brand-new datapack.
     */
    public CreatingDataPack ()
    {
        super();
    }

    /**
     * Load the DataPack at the specified url for remixing.
     */
    public CreatingDataPack (String url, final ResultListener<CreatingDataPack> listener)
    {
        super(url, new ResultListener<EditableDataPack>() {
            public void requestCompleted (EditableDataPack pack) {
                // cast to this subclass
                listener.requestCompleted((CreatingDataPack) pack);
            }

            public void requestFailed (Exception cause) {
                listener.requestFailed(cause);
            }
        });
    }

    /**
     * Replace the specified file with a file that's already in the temp dir.
     * Note that the entry value is not updated.
     */
    public String replaceFile (String name, String tempDirFilename)
        throws IOException
    {
        return replaceFile(name, new File(_tempDir, tempDirFilename));
    }

    /**
     * Replace the specified file, returning the temp-dir filename.
     * Note that the entry value is not updated.
     */
    public String replaceFile (String name, File newFile)
        throws IOException
    {
        name = validateAccess(name);
        FileEntry entry = _metadata.files.get(name);
        if (entry == null) {
            throw new IllegalArgumentException("No file named " + name);
        }

        // see if the specified file needs to be moved to the temporary directory
        byte[] data = readFile(newFile);
        String filename;
        if (_tempDir.equals(newFile.getParentFile())) {
            filename = newFile.getPath();

        } else {
            // copy the data into the temp directory
            filename = createTempFile(newFile, data);
        }

        // remember the new filename
        entry.value = filename;

        // remember the new data
        _files.put(filename, data);
        return filename;
    }

    protected String createTempFile (File newFile, byte[] data)
        throws IOException
    {
        String name = newFile.getName();
        File outFile = new File(_tempDir, name);

        if (outFile.exists()) {
            // see if the existing file contains the same data
            byte[] otherData = readFile(outFile);
            if (Arrays.equals(data, otherData)) {
                // this file already exists and contains the same data
                return outFile.getName();
            }

            // otherwise, try inserting a number before the extension
            int dot = name.lastIndexOf('.');
            String extension = "";
            if (dot != -1) {
                extension = name.substring(dot);
                name = name.substring(0, dot);
            }
            for (int ii = 2; true; ii++) {
                outFile = new File(_tempDir, name + "_" + ii + extension);
                if (!outFile.exists()) {
                    break;
                }
            }
        }

        // copy the file and return the new name
        name = outFile.getName();
        unpackFile(name, data);
        return name;
    }

    protected byte[] readFile (File file)
        throws IOException
    {
        FileInputStream fis = new FileInputStream(file);
        byte[] data = new byte[fis.available()]; // the whole file should be available
        fis.read(data);
        fis.close();
        return data;
    }

    /**
     * Add a new file to this DataPack.
     */
    public void addFile (String filename, String name, FileType type, String desc, boolean optional)
        throws IOException
    {
        File file = new File(filename);
        byte[] data = readFile(file);
        addFile(file.getName(), data, name, type, desc, optional);
    }

    @Override
    protected void didInit ()
    {
        super.didInit();
        unpack();
    }

    /**
     * Unpack the files contained in this datapack into the temporary directory.
     */
    protected void unpack ()
    {
        try {
            // create a temporary directory
            _tempDir = File.createTempFile("datapack", ".tmp");
            boolean result = _tempDir.delete();
            if (result) {
                result = _tempDir.mkdir();
                _tempDir.deleteOnExit();
            }
            if (!result) { // if either result fails..
                throw new IOException("Failure creating temporary directory.");
            }

            // now, unpack any files
            for (Map.Entry<String,byte[]> entry : _files.entrySet()) {
                unpackFile(entry.getKey(), entry.getValue());
            }

        } catch (IOException ioe) {
            ioe.printStackTrace();
            _closed = true;
        }
    }

    /**
     * Write the specified file data to the temporary directory.
     */
    protected void unpackFile (String filename, byte[] data)
        throws IOException
    {
        File outFile = new File(_tempDir, filename);
        outFile.deleteOnExit();
        FileOutputStream fos = new FileOutputStream(outFile);
        try {
            fos.write(data);
        } finally {
            fos.close();
        }
    }

    /**
     * Write this datapack out to the specified filename.
     */
    public void writeTo (String filename)
        throws IOException
    {
        FileOutputStream fos = new FileOutputStream(filename);
        writeTo(fos);
        fos.close();
    }


    /** The temporary file directory. */
    protected File _tempDir;

    // for yon testing
    public static void main (String[] args)
    {
        new CreatingDataPack("http://tasman.sea.earth.threerings.net:8080/ClockPack.dpk",
            new ResultListener<CreatingDataPack>() {
                public void requestCompleted (CreatingDataPack pack)
                {
                    try {
                        //pack.addFile("/home/ray/media/mp3/tarzan and jane - Tarzan & Jane.mp3",
                        //    "music", FileType.BLOB, true);
                        pack.writeTo("/export/msoy/pages/ClockPack.jpk");

                    } catch (IOException ioe) {
                        System.err.println("ioe: " + ioe);
                        ioe.printStackTrace();
                    }
                }

                public void requestFailed (Exception cause)
                {
                    System.err.println("Oh noes: " + cause);
                }
            });
    }
}
