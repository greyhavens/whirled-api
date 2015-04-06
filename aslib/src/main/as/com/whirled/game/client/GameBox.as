//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import flash.display.DisplayObject;

import flash.geom.Rectangle;

import mx.core.mx_internal;
import mx.core.IFlexDisplayObject;
import mx.core.IInvalidating;

import mx.containers.VBox;

import mx.managers.IFocusManagerComponent;

import mx.skins.ProgrammaticSkin;

import com.threerings.crowd.chat.client.ChatCantStealFocus;

import com.threerings.media.MediaContainer;

public class GameBox extends VBox
    implements ChatCantStealFocus
{
    /**
     * Creates a new game container to load the given url but does not actually start loading it.
     */
    public function GameBox (url :String, container :MediaContainer)
    {
        tabEnabled = true; // turned off by Container

        _url = url;
        _container = container;
    }

    /**
     * Starts loading the content of this container.
     */
    public function initiateLoading () :void
    {
        // TODO: instantiate the byte array after completion
        // Note from Ray: This is not as easy as you think, because loading bytes places the
        // content in your own security domain. I think we might be able to load the media stub
        // and ask it to instantiate the bytes, and that might work.

        _container.setMedia(_url);
        rawChildren.addChild(_container);
    }

    protected var _url :String;
    protected var _container :MediaContainer;
}
}
