//
// $Id$

package com.whirled.game.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

/**
 * Describes the functionality available to game clients for sending messages. Each message service 
 * is associated with a specific audience.
 */
public interface WhirledGameMessageService
    extends InvocationService
{
    /**
     * Requests to send a message to the entire audience. 
     * @param client indicates the sender of the request
     * @param msgName the name of the message
     * @param value the value contained in the message
     * @param listener dispatches the error message if the request fails
     */
    public void sendMessage (Client client, String msgName, Object value, 
        InvocationListener listener);

    /**
     * Requests to send a message to a specific subset of the audience member.
     * @param client indicates the sender of the request
     * @param msgName the name of the message
     * @param value the value contained in the message
     * @param members the ids of the members to send the message to
     * @param listener dispatches the error message if the request fails
     */
    public void sendPrivateMessage (Client client, String msgName, Object value, 
        int[] members, InvocationListener listener);
}
