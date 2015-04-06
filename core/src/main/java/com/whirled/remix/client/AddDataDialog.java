//
// $Id$

package com.whirled.remix.client;

import java.awt.Color;

import javax.swing.Action;
import javax.swing.JComponent;
import javax.swing.JPanel;

import com.samskivert.util.StringUtil;

import com.whirled.remix.data.CreatingDataPack;

public class AddDataDialog extends AbstractAddDialog
{
    public AddDataDialog (JComponent host, CreatingDataPack pack, Action popupAction)
    {
        super(host, pack, popupAction);
        setTitle("Add new data field");
    }

    @Override
    protected void createContent (JPanel panel)
    {
        super.createContent(panel);

        for (CreatingDataPack.DataType type : CreatingDataPack.DataType.values()) {
            if (type != CreatingDataPack.DataType.UNKNOWN_TYPE) {
                _type.addItem(type);
            }
        }
    }

    // from AbstractAddDialog
    protected String getTypeHelp ()
    {
        return "The type of the data.";
    }

    // from AbstractAddDialog
    protected void createRow (String name, Object type, String desc)
    {
        _pack.addDataEntry(name, (CreatingDataPack.DataType) type, desc);
    }

    // from AbstractAddDialog
    protected boolean areFieldsValid ()
    {
        String name = _name.getText().trim();
        boolean nameOK = !StringUtil.isBlank(name) && (null == _pack.getDataEntry(name));
        boolean descOK = !StringUtil.isBlank(_desc.getText());
        boolean typeOK = null != _type.getSelectedItem();

        _nameLabel.setForeground(nameOK ? Color.BLACK : Color.RED);
        _descLabel.setForeground(descOK ? Color.BLACK : Color.RED);

        return nameOK && typeOK && descOK;
    }
}
