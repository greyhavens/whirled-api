//
// $Id$

package com.whirled.game.client;

import java.awt.AlphaComposite;
import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Composite;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.Stroke;
import java.awt.geom.AffineTransform;
import java.awt.geom.RoundRectangle2D;

import com.samskivert.swing.Label;
import com.samskivert.swing.util.SwingUtil;

import com.samskivert.util.ResultListener;

import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.ElementUpdateListener;
import com.threerings.presents.dobj.ElementUpdatedEvent;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.SetListener;

import com.threerings.util.Name;

import com.threerings.media.HourglassView;
import com.threerings.media.MediaPanel;
import com.threerings.media.TimerView;
import com.threerings.media.image.Mirage;
import com.threerings.media.tile.TileMultiFrameImage;
import com.threerings.media.tile.UniformTileSet;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.parlor.game.data.GameObject;
import com.threerings.parlor.turn.data.TurnGameObject;

import com.whirled.util.WhirledContext;

/**
 * Displays a player's name and face icon, along with an hourglass and colored background when it's
 * their turn. Can be extended to show various game-specific information.
 */
public class PlayerView
{
    /**
     * Constructs a player status view for the given player index.
     *
     * @param turnDuration the number of ms in a turn, or -1 to disable the timer view.
     */
    public PlayerView (WhirledContext ctx, MediaPanel host, long turnDuration, int pidx,
                       int x, int y, Color background)
    {
        // save things off
        _ctx = ctx;
        _host = host;
        _pidx = pidx;
        _background = background;

        // set the view bounds
        _bounds.setLocation(x, y);
        _bounds.width = getWidth();
        _bounds.height = getHeight();
        _center = new Point(x + _bounds.width/2, y + _bounds.height/2);

        // TODO
        Font font = new Font("Dialog", Font.PLAIN, 10);

        // create the name label
        _nameLabel = new Label("", Label.OUTLINE, Color.white, Color.black, font);
        _nameLabel.setTargetWidth(getLeftWidth());
        _nameLabel.setAlignment(Label.CENTER);
        _nameLabel.layout(_host);

        setTurnDuration(turnDuration);
    }

    /**
     * Get the width that this view should be.
     */
    public int getWidth ()
    {
        return 110;
    }

    /**
     * Get the height that this view should be.
     */
    public int getHeight ()
    {
        return 100;
    }

    /**
     * Returns the size to use for the face icon.
     */
    public Dimension getFaceIconSize ()
    {
        return new Dimension(58, 58); // default to compatibility with YoFaceIcon
    }

    /**
     * Return true if the component should continue rendering the name
     * and any exras even after the player has left the game room.
     */
    protected boolean rendersWhenPlayerAbsent ()
    {
        return true;
    }

    /**
     * How wide the left half of the view is, which includes the player's face icon and name.  The
     * remainer of getWidth() is for the right half of the view.
     */
    public int getLeftWidth ()
    {
        return LEFT_COLUMN_WIDTH;
    }

    /** Return the view's bounding box. */
    public Rectangle getBounds ()
    {
        return _bounds;
    }

    /**
     * Returns the center of the view.
     */
    public Point getCenter ()
    {
        return _center.getLocation();
    }

    /**
     * Sets the turn duration to the time specified.  If the timer is already active, this will
     * have no effect until the next turn.
     */
    public void setTurnDuration (long ms)
    {
        if (ms >= 0 && _timerView == null) {
            // create the timer view
            _timerView = createPuzzleHourglass(_bounds.x + getLeftWidth() - 10, _bounds.y + 20);
            _timerView.setEnabled(false);

        } else if (ms < 0 && _timerView != null) {
            _timerView.setEnabled(false);
            _timerView = null;
        }

        _turnDuration = ms;
    }

    /**
     * Invalidates this view's bounds via the game board view.
     */
    public void invalidate ()
    {
        _host.getRegionManager().invalidateRegion(_bounds);
    }

    /** Test if this view should be rendered. */
    public boolean shouldRender ()
    {
        return (_occinfo != null || rendersWhenPlayerAbsent());
    }

    /**
     * Renders the player status view to the given graphics context.
     */
    public void render (Graphics2D gfx)
    {
        if (!shouldRender()) {
            return;
        }

        // make sure our label is laid out
        Dimension lsize = _nameLabel.getSize();
        if (lsize.width == 0) {
            _nameLabel.layout(gfx);
            lsize = _nameLabel.getSize();
        }

        Object oalias = SwingUtil.activateAntiAliasing(gfx);

        AffineTransform otrans = gfx.getTransform();
        gfx.translate(_bounds.x, _bounds.y);

        if (_showActive) {
            // draw the background
            Composite ocomp = gfx.getComposite();
            gfx.setComposite(ALPHA_BACKGROUND);
            RoundRectangle2D.Float rrect = new RoundRectangle2D.Float(
                1, 1, _bounds.width - 3, _bounds.height - 3, ARC_WIDTH, ARC_HEIGHT);
            gfx.setColor(_background);
            gfx.fill(rrect);

            // draw an outline around the view
            Stroke ostroke = gfx.getStroke();
            gfx.setColor(BORDER_COLOR);
            gfx.setStroke(BORDER_STROKE);
            gfx.draw(rrect);
            gfx.setStroke(ostroke);
            gfx.setComposite(ocomp);
        }

        // paint any extra
        paintExtraAntiAlias(gfx);
        SwingUtil.restoreAntiAliasing(gfx, oalias);
        paintExtra(gfx);

        // draw the name label
        _nameLabel.render(gfx, (getLeftWidth() - lsize.width) / 2, GAP);

        // restore the gfx to the previous state
        gfx.setTransform(otrans);

         // draw the hourglass
        if (_timerView != null) {
            _timerView.render(gfx);
        }
    }

    /**
     * Paint any extra components or status to accompany this view, with anti-aliasing turned on.
     */
    protected void paintExtraAntiAlias (Graphics2D gfx)
    {
        // nothing in this base class
    }

    /**
     * Paint any extra components or status to accompany this view.
     */
    protected void paintExtra (Graphics2D gfx)
    {
        // nothing in this base class
    }

    @Override // documentation inherited
    public String toString ()
    {
        return "[username=" + _username + ", pidx=" + _pidx + "]";
    }

    /**
     * Called to indicate that we're entering the place.
     */
    public void willEnterPlace (PlaceObject placeObject)
    {
        _gameObj = (GameObject)placeObject;
        _turnGameObj = (TurnGameObject)placeObject;
        _gameObj.addListener(_gameListener = createPlaceListener());

        // update according to game state
        updateUsername();
        updateOccupantInfo();
        updateActive();
    }

    /**
     * Called to indicate that we're leaving the place.
     */
    public void didLeavePlace (PlaceObject placeObject)
    {
        _gameObj.removeListener(_gameListener);
    }

    /**
     * Activates or deactivates the view based on whether the represented player current holds the
     * turn.
     */
    public void updateActive ()
    {
        setActive((_username != null) && _username.equals(_turnGameObj.getTurnHolder()));
    }

    /**
     * Activates (at the start of a turn) or deactivates (at the end of a turn) this player status
     * view.  Activated views are highlighted and display an hourglass counting down the amount of
     * time remaining in the turn.
     */
    public void setActive (boolean active)
    {
        if (_active == active) {
            return;
        }

        _active = active;
        updateShowActive(_active);
        if (_timerView != null) {
            if (_active) {
                long dur = getTurnDuration();
                if (dur > 0) {
                    _timerView.setEnabled(true);
                    _timerView.start(0, dur, new ResultListener.NOOP<TimerView>());
                }

            } else {
                _timerView.setEnabled(false);
            }
        }

        // and we need to invalidate even if we don't have a timer because the _active change will
        // affect our background color.
        invalidate();
    }

    /** Make an object to listen for changes in the place object. */
    protected GameListener createPlaceListener ()
    {
        return new GameListener();
    }

    /**
     * Set whether we should draw the background for this view as active.  By default this will
     * always match whether we truly are active, but this behavior may be overridden.
     */
    protected void updateShowActive (boolean active)
    {
        _showActive = active;
    }

    /**
     * Returns the duration of the current turn in milliseconds, or -1 to indicate that the timer
     * should not be shown. Called when the represented player becomes active.
     */
    protected long getTurnDuration ()
    {
        return _turnDuration;
    }

    /**
     * Updates the view to reflect the username of the player.
     */
    protected void updateUsername ()
    {
        if (_gameObj.players[_pidx] == null) {
            _username = null;
            _nameLabel.setText("");
            _nameLabel.layout(_host);
            invalidate();
        } else {
            _username = _gameObj.players[_pidx];
            if (_occinfo != null) {
                _nameLabel.setText(_occinfo.username.toString());
            } else {
                _nameLabel.setText(_username.toString());
            }
            _nameLabel.layout(_host);
            invalidate();
        }
    }

    /**
     * Updates the view to reflect the occupant info of the player.
     */
    protected void updateOccupantInfo ()
    {
        _occinfo = _gameObj.getOccupantInfo(_username);
        invalidate();
    }

    /**
     * Create a standard puzzle hourglass.
     */
    protected HourglassView createPuzzleHourglass (int x, int y)
    {
        String prefix = "images/hourglass/";
        UniformTileSet trickleSet = _ctx.getTileManager().loadTileSet(
            prefix + "hourglass_sand_trickle.png", 2, 20);
        return new HourglassView(_ctx.getFrameManager(), _host, x, y,
                                 loadMirage(prefix + "hourglass.png"),
                                 loadMirage(prefix + "hourglass_sand_top.png"),
                                 new Rectangle(4, 10, 12, 16),
                                 loadMirage(prefix + "hourglass_sand_bottom.png"),
                                 new Rectangle(4, 27, 12, 19),
                                 new TileMultiFrameImage(trickleSet));
    }

    /**
     * Loads a special optimized image format.
     */
    protected Mirage loadMirage (String path)
    {
        return _ctx.getImageManager().getMirage(
            _ctx.getImageManager().getImageKey((String)null, path));
    }

    /** Provides access to client services. */
    protected WhirledContext _ctx;

    /** The host rendering this view. */
    protected MediaPanel _host;

    /** The bounds of this view. */
    protected Rectangle _bounds = new Rectangle();

    /** The center of this view. */
    protected Point _center;

    /** The background color to use. */
    protected Color _background;

    /** A reference to the game object. */
    protected GameObject _gameObj;

    /** A reference to the game object as turn game. */
    protected TurnGameObject _turnGameObj;

    /** Listens to the game object in order to update the view. */
    protected GameListener _gameListener;

    /** Whether this status view is active. */
    protected boolean _active;

    /** Whether this status view should be drawn as active. */
    protected boolean _showActive;

    /** The player index of the player. */
    protected int _pidx;

    /** The occupant info for the player. */
    protected OccupantInfo _occinfo;

    /** The username of the player. */
    protected Name _username;

    /** The username label. */
    protected Label _nameLabel;

    /** The player's character sprite fingerprint. */
    protected int[] _charPrint;

    /** The timer view. */
    protected HourglassView _timerView;

    /** The normal turn duration. */
    protected long _turnDuration;

    /** Listens to the game object in order to update the view. */
    protected class GameListener
        implements AttributeChangeListener, ElementUpdateListener, SetListener<OccupantInfo>
    {
        // Documentation inherited.
        public void attributeChanged (AttributeChangedEvent ace)
        {
            String name = ace.getName();
            if (name.equals(_turnGameObj.getTurnHolderFieldName())) {
                updateActive();

            } else if (name.equals(GameObject.PLAYERS)) {
                updateUsername();
            }
        }

        // Documentation inherited.
        public void elementUpdated (ElementUpdatedEvent eue)
        {
            if (eue.getName().equals(GameObject.PLAYERS) &&
                eue.getIndex() == _pidx) {
                updateUsername();
            }
        }

        // Documentation inherited.
        public void entryAdded (EntryAddedEvent<OccupantInfo> eae)
        {
            if (eae.getName().equals(PlaceObject.OCCUPANT_INFO)) {
                OccupantInfo yoi = eae.getEntry();
                if (yoi.username.equals(_username)) {
                    updateOccupantInfo();
                }
            }
        }

        // Documentation inherited.
        public void entryRemoved (EntryRemovedEvent<OccupantInfo> ere)
        {
            if (ere.getName().equals(PlaceObject.OCCUPANT_INFO)) {
                OccupantInfo yoi = ere.getOldEntry();
                if (yoi.username.equals(_username)) {
                    updateOccupantInfo();
                }
            }
        }

        // Documentation inherited.
        public void entryUpdated (EntryUpdatedEvent<OccupantInfo> eue)
        {
            if (eue.getName().equals(PlaceObject.OCCUPANT_INFO)) {
                OccupantInfo yoi = eue.getEntry();
                if (yoi.username.equals(_username)) {
                    updateOccupantInfo();
                }
            }
        }
    }

    /** The gap in pixels to leave around the edge of the view. */
    protected static final int GAP = 5;

    /** The width of the left hand column. */
    protected static final int LEFT_COLUMN_WIDTH = 80;

    /** The alpha level used to render the view background when this player is the active
     * player. */
    protected static final Composite ALPHA_BACKGROUND =
        AlphaComposite.getInstance(AlphaComposite.SRC_OVER, 0.65f);

    /** The stroke used to render the view border when active. */
    protected static final Stroke BORDER_STROKE = new BasicStroke(2);

    /** The color used to render the view border when active. */
    protected static final Color BORDER_COLOR = new Color(0xfafafa);

    /** The width of the border round-rect in pixels. */
    protected static final float ARC_WIDTH = 20;

    /** The height of the border round-rect in pixels. */
    protected static final float ARC_HEIGHT = 20;
}
