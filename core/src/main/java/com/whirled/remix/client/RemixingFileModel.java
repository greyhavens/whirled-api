//
// $Id$

package com.whirled.remix.client;

import java.io.File;
import java.io.IOException;

import java.util.List;

import com.samskivert.util.StringUtil;

import com.whirled.remix.data.CreatingDataPack;

/**
 */
public class RemixingFileModel extends AbstractModel
{
    public RemixingFileModel (CreatingDataPack pack, RemixingFileTable table)
    {
        super(pack);
        _table = table;
    }

    @Override
    public String getColumnName (int column)
    {
        switch (column) {
        case VALUE_COL:
            return "File";

        default:
            return super.getColumnName(column);
        }
    }

    @Override
    public void setValueAt (Object newValue, int row, int column)
    {
        if (column == ACTIONS_COL && ((Integer) newValue).intValue() == ACTION_VIEW) {
            _table.viewFile(row, column);
            return;
        }

        // --- from this point forward, we WILL call super(), we do not return from these
        // special if statements, they are done in addition to setting the value in the superclass

        try {
            if (column == VALUE_COL) {
                File newFile = (File) newValue;
                CreatingDataPack.AbstractEntry entry = getEntry(row);
                newValue = _pack.replaceFile(entry.name, newFile);

            } else if (column == ACTIONS_COL && ((Integer) newValue).intValue() == ACTION_REVERT) {
                CreatingDataPack.AbstractEntry entry = getEntry(row);
                String oldFilename = (String) _revertValues.get(entry.name);
                if (!StringUtil.isBlank(oldFilename)) {
                    _pack.replaceFile(entry.name, oldFilename);
                }
            }
        } catch (IOException ioe) {
            ioe.printStackTrace();
            return;
        }

        super.setValueAt(newValue, row, column);
    }

    // from AbstractModel
    protected List<String> initFields (CreatingDataPack pack)
    {
        return pack.getFileFields();
    }

    // from AbstractModel
    protected CreatingDataPack.AbstractEntry getEntry (int rowIndex)
    {
        return _pack.getFileEntry(_fields.get(rowIndex));
    }

    protected RemixingFileTable _table;
}
