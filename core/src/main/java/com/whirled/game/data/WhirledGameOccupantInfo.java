//
// $Id$
//
// Copyright (c) 2007 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;

/**
 * Extends OccupantInfo with a 'initialized' flag for flash games.
 */
public class WhirledGameOccupantInfo extends OccupantInfo
{
    /** False until the usercode has connected to the backend. */
    public boolean initialized;

    /** Used when unserializing. */
    public WhirledGameOccupantInfo ()
    {
    }

    /**
     * Creates an info record for the specified player.
     */
    public WhirledGameOccupantInfo (BodyObject body)
    {
        super(body);
    }
}
