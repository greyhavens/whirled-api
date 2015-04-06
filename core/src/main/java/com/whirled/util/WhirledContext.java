//
// $Id$

package com.whirled.util;

import java.awt.image.BufferedImage;

import com.threerings.crowd.data.BodyObject;

import com.threerings.media.FrameManager;
import com.threerings.media.image.ImageManager;
import com.threerings.media.sound.SoundPlayer;
import com.threerings.media.tile.TileManager;

import com.threerings.resource.ResourceManager;

import com.threerings.util.KeyDispatcher;
import com.threerings.util.MessageBundle;
import com.threerings.util.MessageManager;
import com.threerings.util.Name;

import com.whirled.game.util.WhirledGameContext;

/**
 * Extends the context with Whirled bits.
 */
public abstract class WhirledContext
    implements WhirledGameContext
{
    /**
     * Provides image loading and caching.
     */
    public abstract ImageManager getImageManager ();

    /**
     * Provides tileset loading and caching.
     */
    public abstract TileManager getTileManager ();

    /**
     * Provides a means for loading and playing sounds.
     */
    public abstract SoundPlayer getSoundManager ();

    /**
     * Returns a reference to the message manager used by the client to
     * generate localized messages.
     */
    public abstract MessageManager getMessageManager ();

    /**
     * Returns a reference to our frame manager (used for media services).
     */
    public abstract FrameManager getFrameManager ();

    /**
     * Returns a reference to our key dispatcher.
     */
    public abstract KeyDispatcher getKeyDispatcher ();

    /**
     * Returns the resource manager which is used to load media resources.
     */
    public abstract ResourceManager getResourceManager ();

    /**
     * Translates the specified message using the specified message bundle.
     */
    public String xlate (String bundle, String message)
    {
        MessageBundle mb = getMessageManager().getBundle(bundle);
        return (mb == null) ? message : mb.xlate(message);
    }

    /**
     * Convenience method to get the username of the currently logged on
     * user. Returns null when we're not logged on.
     */
    public Name getUsername ()
    {
        BodyObject bobj = (BodyObject)getClient().getClientObject();
        return (bobj == null) ? null : bobj.getVisibleName();
    }

    /**
     * Convenience method to load an image from our resource bundles.
     */
    public BufferedImage loadImage (String rsrcPath)
    {
        return getImageManager().getImage(rsrcPath);
    }
}
