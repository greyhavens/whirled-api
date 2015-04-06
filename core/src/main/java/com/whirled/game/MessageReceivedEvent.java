//
// $Id$

package com.whirled.game;

public class MessageReceivedEvent extends WhirledGameEvent
{
    public MessageReceivedEvent (WhirledGame game, String messageName, Object value)
    {
        super(game);
        _name = messageName;
        _value = value;
    }

    /**
     * Access the message name.
     */
    public String getName ()
    {
        return _name;
    }

    /**
     * Access the message value.
     */
    public Object getValue ()
    {
        return _value;
    }

    public String toString ()
    {
        return "[MessageReceivedEvent name=" + _name + ", value=" + _value + "]";
    }

    protected String _name;
    protected Object _value;
}
