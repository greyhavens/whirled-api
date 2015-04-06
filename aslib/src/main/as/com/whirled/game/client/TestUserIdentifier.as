//
// $Id$

package com.whirled.game.client {

import com.threerings.util.Name;
import com.threerings.util.StringUtil;

import com.threerings.parlor.game.data.UserIdentifier;

/**
 * Simply holds a function we use to identify users.
 */
public class TestUserIdentifier
{
    public static function getUserId (name :Name) :int
    {
        var username :String = name.toString();
        try {
            return StringUtil.parseInteger(username.substring(username.lastIndexOf("_")+1));
        } catch (e :Error) {
            // below
        }
        return -1 * Math.abs(StringUtil.hashCode(username));
    }
}
}
