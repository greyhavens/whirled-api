//
// $Id$

package com.whirled.game.data;

/**
 * A file parameter for representing downloadable item packs on the test server.
 */
public class ItemPackParameter extends ContentPackParameter
{
    public GameData toGameData ()
    {
        ItemData data = new ItemData();
        data.ident = this.ident;
        data.name = this.name;
        data.mediaURL = this.mediaURL;
        return data;
    }
}
