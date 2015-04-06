//
// $Id$

package com.whirled.remix.client;

import java.util.List;

import com.whirled.remix.data.CreatingDataPack;

/**
 */
public class RemixingDataModel extends AbstractModel
{
    public RemixingDataModel (CreatingDataPack pack)
    {
        super(pack);
    }

    @Override
    public Object getValueAt (int rowIndex, int columnIndex)
    {
        switch (columnIndex) {
        case DEFAULT_COL:
            CreatingDataPack.DataEntry entry = (CreatingDataPack.DataEntry) getEntry(rowIndex);
            return entry.defaultValue;

        default:
            return super.getValueAt(rowIndex, columnIndex);
        }
    }

    // from AbstractModel
    protected List<String> initFields (CreatingDataPack pack)
    {
        return pack.getDataFields();
    }

    // from AbstractModel
    protected CreatingDataPack.AbstractEntry getEntry (int rowIndex)
    {
        return _pack.getDataEntry(_fields.get(rowIndex));
    }
}
