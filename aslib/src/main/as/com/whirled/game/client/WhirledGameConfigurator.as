//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.game.client {

import mx.core.UIComponent;
import mx.controls.CheckBox;
import mx.controls.ComboBox;
import mx.controls.HSlider;
import mx.controls.Label;

import com.threerings.util.Integer;
import com.threerings.util.Log;
import com.threerings.util.StreamableHashMap;
import com.threerings.util.StringUtil;
import com.threerings.util.langBoolean;

import com.threerings.flex.LabeledSlider;

import com.threerings.parlor.game.client.FlexGameConfigurator;

import com.threerings.parlor.data.Parameter;
import com.threerings.parlor.data.ChoiceParameter;
import com.threerings.parlor.data.RangeParameter;
import com.threerings.parlor.data.ToggleParameter;

import com.whirled.game.data.WhirledGameConfig;

/**
 * Adds custom configuration of options specified in XML.
 */
public class WhirledGameConfigurator extends FlexGameConfigurator
{
    public function WhirledGameConfigurator (ratedParam :ToggleParameter = null)
    {
        _ratedParam = ratedParam;
    }

    // from GameConfigurator
    override protected function gotGameConfig () :void
    {
        super.gotGameConfig();

        // add an interface for checking ratedness
        if (_ratedParam != null) {
            _ratedCheck = new CheckBox();
            _ratedCheck.styleName = "gconfCheckBox";
            _ratedCheck.selected = _ratedParam.start;
            addLabeledControl(_ratedParam, _ratedCheck);
        }

        var params :Array = (_config as WhirledGameConfig).getGameDefinition().params;
        if (params == null) {
            return;
        }

        for each (var param :Parameter in params) {
            if (param is RangeParameter) {
                var range :RangeParameter = (param as RangeParameter);
                if ((range.maximum - range.minimum) < 16) {
                    var rcombo :ComboBox = new ComboBox();
                    rcombo.styleName = "gconfComboBox";
                    var values :Array = [];
                    var rstartDex :int = 0;
                    for (var ii :int = range.minimum; ii <= range.maximum; ii++) {
                        if (ii == range.start) {
                            rstartDex = ii;
                        }
                        values.push(new Integer(ii));
                    }
                    rcombo.dataProvider = values;
                    rcombo.selectedIndex = rstartDex;
                    addLabeledControl(param, rcombo);

                } else {
                    var slider :HSlider = new HSlider();
                    slider.styleName = "gconfHSlider";
                    slider.minimum = range.minimum;
                    slider.maximum = range.maximum;
                    slider.value = range.start;
                    slider.liveDragging = true;
                    slider.snapInterval = 1;
                    addLabeledControl(param, new LabeledSlider(slider));
                }

            } else if (param is ChoiceParameter) {
                var choice :ChoiceParameter = (param as ChoiceParameter);
                var startDex :int = choice.choices.indexOf(choice.start);
                if (startDex == -1) {
                    Log.getLog(this).warning(
                        "Start value does not appear in list of choices [param=" + choice + "].");
                } else {
                    var combo :ComboBox = new ComboBox();
                    combo.styleName = "gconfComboBox";
                    combo.dataProvider = choice.choices;
                    combo.selectedIndex = startDex;
                    addLabeledControl(param, combo);
                }

            } else if (param is ToggleParameter) {
                var check :CheckBox = new CheckBox();
                check.styleName = "gconfCheckBox";
                check.selected = (param as ToggleParameter).start;
                addLabeledControl(param, check);

            } else {
                Log.getLog(this).warning("Unknown parameter in config [param=" + param + "].");
            }
        }
    }

    override protected function flushGameConfig () :void
    {
        super.flushGameConfig();

        // flush ratedness
        if (_ratedCheck != null) {
            _config.rated = _ratedCheck.selected;
        }

        // if there were any custom XML configs, flush those as well.
        if (_customConfigs.length > 0) {
            var params :StreamableHashMap = new StreamableHashMap(String);

            for (var ii :int = 0; ii < _customConfigs.length; ii += 2) {
                var ident :String = String(_customConfigs[ii]);
                var control :UIComponent = (_customConfigs[ii + 1] as UIComponent);
                if (control is LabeledSlider) {
                    // this is wrapped in our own Integer class so that it can play in a friendly 
                    // way with Java that deserializes this StreamableHashMap
                    params.put(ident, new Integer((control as LabeledSlider).slider.value));

                } else if (control is CheckBox) {
                    // ditto above
                    params.put(ident, new langBoolean((control as CheckBox).selected));

                } else if (control is ComboBox) {
                    params.put(ident, (control as ComboBox).selectedItem);

                } else {
                    Log.getLog(this).warning("Unknow custom config type " + control);
                }
            }

            (_config as WhirledGameConfig).params = params;
        }
    }

    /**
     * Add a control that came from parsing our custom option XML.
     */
    protected function addLabeledControl (param :Parameter, control :UIComponent) :void
    {
        if (StringUtil.isBlank(param.name)) {
            param.name = param.ident;
        }

        var lbl :Label = new Label();
        lbl.text = param.name;
        lbl.styleName = "lobbyLabel";
        lbl.toolTip = param.tip;
        control.toolTip = param.tip;

        addControl(lbl, control);
        _customConfigs.push(param.ident, control);
    }

    /** The parameter to use for whether the game is rated, or null. */
    protected var _ratedParam :ToggleParameter;

    /** A toggle indicating whether the game should be rated. */
    protected var _ratedCheck :CheckBox;

    /** Contains pairs of identString, control, identString, control.. */
    protected var _customConfigs :Array = [];
}
}
