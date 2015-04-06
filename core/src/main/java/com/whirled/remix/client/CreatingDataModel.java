//
// $Id$

package com.whirled.remix.client;

import com.whirled.remix.data.CreatingDataPack;

/**
 */
public class CreatingDataModel extends RemixingDataModel
{
    public CreatingDataModel (CreatingDataPack pack)
    {
        super(pack);
        _deleteRows = true;
        _blockRevert = true;
    }

    @Override
    public boolean isCellEditable (int rowIndex, int columnIndex)
    {
        switch (columnIndex) {
        case AbstractModel.INFO_COL:
        case AbstractModel.REQUIRED_COL:
        case AbstractModel.DEFAULT_COL:
            return true;

        default:
            return super.isCellEditable(rowIndex, columnIndex);
        }
    }

    @Override
    public void setValueAt (Object newValue, int rowIndex, int columnIndex)
    {
        switch (columnIndex) {
        case DEFAULT_COL:
            CreatingDataPack.DataEntry entry = (CreatingDataPack.DataEntry) getEntry(rowIndex);
            entry.defaultValue = newValue;
            break;

        default:
            super.setValueAt(newValue, rowIndex, columnIndex);
            break;
        }
    }

    @Override
    protected void deleteRow (int rowIndex, String entryName)
    {
        _pack.removeDataEntry(entryName);
    }
}
