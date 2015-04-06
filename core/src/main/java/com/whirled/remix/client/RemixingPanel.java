//
// $Id$

package com.whirled.remix.client;

import java.awt.event.ActionEvent;

import java.io.IOException;

import javax.swing.AbstractAction;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTable;

import com.samskivert.swing.GroupLayout;
import com.samskivert.swing.VGroupLayout;

import com.whirled.remix.data.CreatingDataPack;

public class RemixingPanel extends JPanel
{
    public RemixingPanel (CreatingDataPack pack)
    {
        super(new VGroupLayout(
            VGroupLayout.STRETCH, VGroupLayout.STRETCH, 5, //VGroupLayout.DEFAULT_GAP,
            VGroupLayout.CENTER));

        _pack = pack;

        add(new JLabel("Data"), VGroupLayout.FIXED);
        _dataTable = createDataTable(pack);
        add(new JScrollPane(_dataTable));
        addDataControls();

        add(new JSeparator(), VGroupLayout.FIXED);

        add(new JLabel("Files"), VGroupLayout.FIXED);
        _fileTable = createFileTable(pack);
        add(new JScrollPane(_fileTable));
        addFileControls();

        JPanel buttonPan = GroupLayout.makeButtonBox(GroupLayout.CENTER);
        JButton ok = new JButton(new AbstractAction("Close and Save") {
            public void actionPerformed (ActionEvent event) {
                close(true);
            }
        });
        buttonPan.add(ok);
        JButton cancel = new JButton(new AbstractAction("Cancel") {
            public void actionPerformed (ActionEvent event) {
                close(false);
            }
        });
        buttonPan.add(cancel);

        add(buttonPan, VGroupLayout.FIXED);
    }

    /**
     * Create the table model to use for the data elements.
     */
    protected JTable createDataTable (CreatingDataPack pack)
    {
        return new RemixingDataTable(pack);
    }

    /**
     * Create the table model to use for the file elements.
     */
    protected JTable createFileTable (CreatingDataPack pack)
    {
        return new RemixingFileTable(pack);
    }

    /**
     * Close this panel, optionally saving.
     */
    protected void close (boolean save)
    {
        if (save) {
            // TODO
            try {
                _pack.writeTo("/tmp/datapack.dpk");
            } catch (IOException ioe) {
                ioe.printStackTrace();
            }
        }

        // exit
        System.exit(0);
    }

    /**
     * Add any controls related to the data fields.
     */
    protected void addDataControls ()
    {
        // nada
    }

    /**
     * Add any controls related to the file fields.
     */
    protected void addFileControls ()
    {
        // nada
    }

    /** The DataPack we're editing. */
    protected CreatingDataPack _pack;

    /** The table editing the data fields. */
    protected JTable _dataTable;

    /** The table editing the file fields. */
    protected JTable _fileTable;
}
