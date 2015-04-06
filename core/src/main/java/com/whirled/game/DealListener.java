//
// $Id$

package com.whirled.game;

public interface DealListener
{
    /**
     * Informs the listener that the deal has succeeded or failed. 
     * @param someValue On success, the number of elements dealt. On failure, 0.
     */
    public void dealt (int someValue);
}
