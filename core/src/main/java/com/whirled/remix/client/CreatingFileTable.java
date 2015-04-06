//
// $Id$

package com.whirled.remix.client;

import com.whirled.remix.data.CreatingDataPack;

public class CreatingFileTable extends RemixingFileTable
{
    public CreatingFileTable (CreatingDataPack pack)
    {
        super(pack);
    }

    @Override // from AbstractTable
    protected AbstractModel createModel (CreatingDataPack pack)
    {
        return new CreatingFileModel(pack, this);
    }
}
