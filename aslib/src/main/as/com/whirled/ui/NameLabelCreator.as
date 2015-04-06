//
// $Id$
//
// Copyright (c) 2007-2009 Three Rings Design, Inc. Please do not redistribute.

package com.whirled.ui {

import mx.core.UIComponent;

import com.threerings.util.Name;

public interface NameLabelCreator 
{
    function createLabel (name :Name, extraInfo :Object) :NameLabel;
}
}
