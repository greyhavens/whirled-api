//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.Streamable;
import com.threerings.io.TypedArray;

import com.threerings.parlor.data.Parameter;
import com.threerings.parlor.data.ChoiceParameter;
import com.threerings.parlor.data.RangeParameter;
import com.threerings.parlor.data.ToggleParameter;

/**
 * Contains the information about a game as described by the game definition XML file.
 */
public /*abstract*/ class GameDefinition
    implements Streamable
{
    /** A string identifier for the game. */
    public var ident :String;

    /** The class name of the <code>GameController</code> derivation that we use to bootstrap on
     * the client. */
    public var controller :String;

    /** The class name of the <code>GameManager</code> derivation that we use to manage the game on
     * the server. */
    public var manager :String;

    /** The MD5 digest of the game media file. */
    public var digest :String;

    /** The configuration of the match-making mechanism. */
    public var match :MatchConfig;

    /** Parameters used to configure the game itself. */
    public var params :TypedArray;

    /** The class name to use when launching the game's agent on the server. */
    public var server :String;

    public function GameDefinition ()
    {
    }

    /**
     * Provides the path to this game's media (a jar file or an SWF).
     *
     * @param gameId the unique id of the game provided when this game definition was registered
     * with the system, or -1 if we're running in test mode.
     */
    public function getMediaPath (gameId :int) :String
    {
        throw new Error("abstract");
    }

    /**
     * Provides the path to this game's server media (an abc file). Returns null by default. 
     * Modules that want to support running game code on the server should override this method.
     *
     * @param gameId the unique id of the game provided when this game definition was registered
     * with the system, or -1 if we're running in test mode.
     * @return the path or null if no server media is required for this game.
     */
    public function getServerMediaPath (gameId :int) :String
    {
        return null;
    }

    /**
     * Returns true if a single player can play this game (possibly against AI opponents), or if
     * opponents are needed.
     */
    public function isSinglePlayerPlayable () :Boolean
    {
        throw new Error("Not implemented");
    }

    /** Generates a string representation of this instance. */
    public function toString () :String
    {
        return "[ident=" + ident + ", ctrl=" + controller + ", mgr=" + manager +
            ", match=" + match + ", params=" + params + ", digest=" + digest + 
            ", server=" + server + "]";
    }

    // from interface Streamable
    public function readObject (ins :ObjectInputStream) :void
    {
        ident = (ins.readField(String) as String);
        controller = (ins.readField(String) as String);
        manager = (ins.readField(String) as String);
        digest = (ins.readField(String) as String);
        match = MatchConfig(ins.readObject());
        params = TypedArray(ins.readObject());
        server = (ins.readField(String) as String);
    }

    // from interface Streamable
    public function writeObject (out :ObjectOutputStream) :void
    {
        out.writeField(ident);
        out.writeField(controller);
        out.writeField(manager);
        out.writeField(digest);
        out.writeObject(match);
        out.writeObject(params);
        out.writeField(server);
    }

    /** This function is required to ensure that the compiler includes certain classes. */
    public function fuckingCompiler () :void
    {
        var c :Class;
        // Parameter derivations
        c = RangeParameter;
        c = ToggleParameter;
        c = ChoiceParameter;
        // MatchConfig derivations
        c = TableMatchConfig;
    }
}
}
