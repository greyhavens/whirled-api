package com.whirled.thane {

import com.whirled.bureau.client.UserCodeLoader;
import com.whirled.bureau.client.UserCode;
import com.whirled.bureau.client.WhirledBureauClient;

/** Thane implemenation of <code>UserCodeLoader</code>. */
public class HttpUserCodeLoader 
    implements UserCodeLoader
{
    WhirledBureauClient;    // a free-floating reference just to pull this class in

    /** @inheritDoc */
    // from UserCodeLoader
    public function load (
        url :String, className :String, traceFn :Function, callback :Function) :void
    {
        // this will install its own socket callbacks and invoke the caller's 
        // callback when everything is ready.
        new HttpUserCode(url, className, callback, traceFn);
    }
}
}
