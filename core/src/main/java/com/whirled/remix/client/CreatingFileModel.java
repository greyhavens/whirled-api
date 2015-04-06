//
// $Id$

package com.whirled.remix.client;

import com.whirled.remix.data.CreatingDataPack;

/**
 */
public class CreatingFileModel extends RemixingFileModel
{
    public CreatingFileModel (CreatingDataPack pack, CreatingFileTable table)
    {
        super(pack, table);
        _deleteRows = true;
        _blockRevert = true;
    }

    @Override
    public boolean isCellEditable (int rowIndex, int columnIndex)
    {
        switch (columnIndex) {
        case AbstractModel.INFO_COL:
        case AbstractModel.REQUIRED_COL:
            return true;

        default:
            return super.isCellEditable(rowIndex, columnIndex);
        }
    }

    @Override
    protected void deleteRow (int rowIndex, String entryName)
    {
        _pack.removeFileEntry(entryName);
    }
}
