//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.net {

public class NetConstants
{
    /** Properties beginning with this string will be restored on the next session. */
    public static const PERSISTENT :String = "@";

    /**
     * Transform a name to a persistent name. Has no effect for names that
     * are already persistent.
     */
    public static function makePersistent (name :String) :String
    {
        if (PERSISTENT == name.substring(0, PERSISTENT.length)) {
            return name;
        }
        return PERSISTENT + name;
    }

    /**
     * Transforms a persistent name back to a transient one. Has no effect for names
     * that aren't already persistent.
     */
    public static function makeTransient (name :String) :String
    {
        if (PERSISTENT != name.substring(0, PERSISTENT.length)) {
            return name;
        }
        return name.substring(PERSISTENT.length);
    }
}
}
