//
// $Id$

package com.whirled.remix.client;

import javax.swing.JFrame;

import com.samskivert.util.ResultListener;

import com.whirled.remix.data.CreatingDataPack;

public class RemixingApp
{
    public static void main (String[] args)
    {
        if (args.length == 0) {
            JFrame frame = new JFrame("Creating");
            frame.setContentPane(new CreatingPanel());
            frame.pack();
            frame.setVisible(true);
            return;
        }

        new CreatingDataPack(args[0], new ResultListener<CreatingDataPack>() {
            public void requestCompleted (CreatingDataPack pack) {
                JFrame frame = new JFrame("Remixing");
                frame.setContentPane(new RemixingPanel(pack));
                frame.pack();
                frame.setVisible(true);
            }

            public void requestFailed (Exception cause) {
                cause.printStackTrace();
                System.exit(1);
            }
        });
    }
}
