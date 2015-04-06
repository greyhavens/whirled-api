//
// $Id$

package com.whirled.server;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.Charset;

import org.apache.mina.common.ByteBuffer;
import org.apache.mina.common.IdleStatus;
import org.apache.mina.common.IoAcceptor;
import org.apache.mina.common.IoHandlerAdapter;
import org.apache.mina.common.IoSession;
import org.apache.mina.common.SimpleByteBufferAllocator;
import org.apache.mina.filter.codec.ProtocolCodecFilter;
import org.apache.mina.filter.codec.textline.TextLineCodecFactory;
import org.apache.mina.transport.socket.nio.SocketAcceptor;
import org.apache.mina.transport.socket.nio.SocketAcceptorConfig;

import static com.whirled.Log.log;

/**
 * A class that listens to "XMLSOCKET" requests from Flash clients. These are straight TCP
 * connections, where the client initiates with a <policy-file-request/> line and the server
 * returns a bit of XML -- in fact, we can just send the XML right away.
 */
public class PolicyServer extends IoHandlerAdapter
{
    /**
     * Initializes the policy server and begins listening for requests on the policy port.
     */
    public static IoAcceptor init (
        int socketPolicyPort, String publicServerHost, int[] serverPorts, int gameServerPort)
        throws IOException
    {
        // The following two lines change the default buffer type to 'heap', which yields better
        // performance according to the Apache MINA documentation.
        ByteBuffer.setUseDirectBuffers(false);
        ByteBuffer.setAllocator(new SimpleByteBufferAllocator());

        IoAcceptor acceptor = new SocketAcceptor();
        final SocketAcceptorConfig cfg = new SocketAcceptorConfig();
        cfg.getFilterChain().addLast(
            "codec", new ProtocolCodecFilter(new TextLineCodecFactory(Charset.forName("UTF-8"))));

        log.info("Policy server listening on port " + socketPolicyPort + ".");
        acceptor.bind(new InetSocketAddress(socketPolicyPort),
            new PolicyServer(socketPolicyPort, publicServerHost, serverPorts, gameServerPort), cfg);
        return acceptor;
    }

    /** Create a new server instance. */
    public PolicyServer (
        int socketPolicyPort, String publicServerHost, int[] serverPorts, int gameServerPort)
    {
        // build the XML once and for all
        StringBuilder policyBuilder = new StringBuilder().
            append("<?xml version=\"1.0\"?>\n").
            append("<cross-domain-policy>\n");
        // if we're running on 843, serve a master policy file
        if (socketPolicyPort == MASTER_PORT) {
            policyBuilder.append(
                "  <site-control permitted-cross-domain-policies=\"master-only\"/>\n");
        }

        for (String host : new String[] { publicServerHost }) {
            policyBuilder.append("  <allow-access-from domain=\"").append(host).append("\"");
            policyBuilder.append(" to-ports=\"");
            // allow Flash connections on our server & game ports
            for (int port : serverPorts) {
                policyBuilder.append(port).append(",");
            }
            policyBuilder.append(gameServerPort).append("\"/>\n");
        }
        policyBuilder.append("</cross-domain-policy>\n");

        _policy = policyBuilder.toString();
    }

    @Override
    public void messageReceived (IoSession session, Object msg) {
        // ignored
    }

    @Override
    public void sessionIdle (IoSession session, IdleStatus status)
        throws Exception
    {
        session.close();
    }

    @Override
    public void sessionCreated (IoSession session)
        throws Exception
    {
        session.write(_policy);
        session.setIdleTime(IdleStatus.WRITER_IDLE, 1);
    }

    @Override
    public void exceptionCaught (IoSession session, Throwable cause)
    {
        if (cause instanceof IOException) {
            log.info("PolicyServer session hiccup",
                     "addr", session.getRemoteAddress(), "cause", cause);
        } else {
            log.warning("PolicyServer session failure", "addr", session.getRemoteAddress(), cause);
        }
    }

    protected String _policy;

    protected static final int MASTER_PORT = 843;
}
