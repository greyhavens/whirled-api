//
// $Id$

package com.whirled.remix.client;

import java.awt.event.ActionEvent;

import javax.swing.AbstractAction;
import javax.swing.JButton;
import javax.swing.JPanel;
import javax.swing.JTable;

import com.samskivert.swing.GroupLayout;
import com.whirled.remix.data.CreatingDataPack;

public class CreatingPanel extends RemixingPanel
{
    public CreatingPanel ()
    {
        super(new CreatingDataPack());
    }

    @Override
    protected JTable createDataTable (CreatingDataPack pack)
    {
        return new CreatingDataTable(pack);
    }

    @Override
    protected JTable createFileTable (CreatingDataPack pack)
    {
        return new CreatingFileTable(pack);
    }

    @Override
    protected void addDataControls ()
    {
        JPanel pan = GroupLayout.makeButtonBox(GroupLayout.CENTER);
        pan.add(new JButton(new AbstractAction("Add new data field") {
            public void actionPerformed (ActionEvent event) {
                setEnabled(false);
                new AddDataDialog(CreatingPanel.this, _pack, this);
            }
        }));
        add(pan, GroupLayout.FIXED);
    }

    @Override
    protected void addFileControls ()
    {
        JPanel pan = GroupLayout.makeButtonBox(GroupLayout.CENTER);
        pan.add(new JButton(new AbstractAction("Add new file field") {
            public void actionPerformed (ActionEvent event) {
                setEnabled(false);
                new AddFileDialog(CreatingPanel.this, _pack, this);
            }
        }));
        add(pan, GroupLayout.FIXED);
    }
}
