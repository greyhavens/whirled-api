//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.net.impl {

import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.net.MessageSubControl;

public class MessageSubControlAdapter extends AbstractSubControl
    implements MessageSubControl
{
    public function MessageSubControlAdapter (ctrl :AbstractControl, sendMessage :Function)
    {
        super(ctrl);
        _sendMessage = sendMessage;
    }

    /** @inheritDoc */
    public function sendMessage (name :String, value :Object = null) :void
    {
        _sendMessage(name, value);
    }

    /** @private */
    protected var _sendMessage :Function;
}
}
