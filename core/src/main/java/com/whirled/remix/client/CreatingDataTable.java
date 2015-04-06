//
// $Id$

package com.whirled.remix.client;

import com.whirled.remix.data.CreatingDataPack;

public class CreatingDataTable extends RemixingDataTable
{
    public CreatingDataTable (CreatingDataPack pack)
    {
        super(pack);
    }

    @Override // from AbstractTable
    protected AbstractModel createModel (CreatingDataPack pack)
    {
        return new CreatingDataModel(pack);
    }
}
