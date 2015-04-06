//
// $Id$

package com.whirled.remix.client;

import java.util.List;
import java.util.HashMap;

import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import javax.swing.table.AbstractTableModel;

import com.samskivert.util.ObjectUtil;
import com.samskivert.util.StringUtil;

import com.whirled.remix.data.CreatingDataPack;

/**
 */
public abstract class AbstractModel extends AbstractTableModel
{
    public static final int NAME_COL = 0;
    public static final int INFO_COL = 1;
    public static final int TYPE_COL = 2;
    public static final int VALUE_COL = 3;
    public static final int DEFAULT_COL = 4;
    public static final int REQUIRED_COL = 5;
    public static final int ACTIONS_COL = 6; // actions will have buttons to revert
    public static final int COLUMN_COUNT = 7;

    /** Flags set in the action field. */
    public static final int ACTION_SHOW_REVERT = 1 << 0;
    public static final int ACTION_REVERT = 1 << 1;
    public static final int ACTION_DELETE = 1 << 2;
    public static final int ACTION_VIEW = 1 << 3;

    public AbstractModel (CreatingDataPack pack)
    {
        _pack = pack;
        _fields = initFields(pack);

        pack.addChangeListener(new ChangeListener() {
            public void stateChanged (ChangeEvent event) {
                _fields = initFields(_pack);

                // drop now-unneeded revert values
                _revertValues.keySet().retainAll(_fields);

                fireTableDataChanged();
            }
        });
    }

    /**
     * Return the desired preferred column width for the specified column.
     */
    public int getPreferredColumnWidth (int column)
    {
        switch (column) {
        case INFO_COL:
        case VALUE_COL:
            return 250;

        default:
            return 100;
        }
    }

    // from TableModel
    public int getRowCount ()
    {
        return _fields.size();
    }

    // from TableModel
    public int getColumnCount ()
    {
        return COLUMN_COUNT;
    }

    // from TableModel
    public Object getValueAt (int rowIndex, int columnIndex)
    {
        CreatingDataPack.AbstractEntry entry = getEntry(rowIndex);
        switch (columnIndex) {
        case NAME_COL:
            return entry.name;

        case INFO_COL:
            return entry.info;

        case TYPE_COL:
            return entry.getType();

        case VALUE_COL:
            return entry.value;

        case REQUIRED_COL:
            return !entry.optional;

        case ACTIONS_COL:
            int flags = 0;
            if (!_blockRevert) {
                flags |= ACTION_SHOW_REVERT;
            }
            if (_revertValues.containsKey(entry.name)) {
                flags |= ACTION_REVERT;
            }
            if (entry instanceof CreatingDataPack.FileEntry &&
                    !StringUtil.isBlank((String) entry.value)) {
                flags |= ACTION_VIEW;
            }
            if (_deleteRows) {
                flags |= ACTION_DELETE;
            }
            return Integer.valueOf(flags);

        default:
            return null;
        }
    }

    @Override
    public String getColumnName (int column)
    {
        switch (column) {
        case NAME_COL:
            return "Name";

        case INFO_COL:
            return "Description";

        case TYPE_COL:
            return "Type";

        case VALUE_COL:
            return "Value";

        case REQUIRED_COL:
            return "Required";

        case DEFAULT_COL:
            return "Default";

        case ACTIONS_COL:
            return "Actions";

        default:
            return "UNKNOWN";
        }
    }

    @Override
    public Class<?> getColumnClass (int column)
    {
        switch (column) {
        default:
            return String.class;

        case VALUE_COL:
        case DEFAULT_COL:
            return Object.class;

        case REQUIRED_COL:
            return Boolean.class;

        case ACTIONS_COL:
            return Integer.class;
        }
    }

    @Override
    public boolean isCellEditable (int rowIndex, int columnIndex)
    {
        switch (columnIndex) {
        case VALUE_COL: // standardly, the only editable field is the value
        case ACTIONS_COL: // this is editable so we can push the buttons...
            return true;

        default:
            return false;
        }
    }

    @Override
    public void setValueAt (Object newValue, int rowIndex, int columnIndex)
    {
        CreatingDataPack.AbstractEntry entry = getEntry(rowIndex);
        switch (columnIndex) {
        case VALUE_COL:
            // (We use containsKey in case the value stored is null)
            if (_revertValues.containsKey(entry.name)) {
                Object prevValue = _revertValues.get(entry.name);
                if (ObjectUtil.equals(prevValue, newValue)) {
                    _revertValues.remove(entry.name);
                    fireTableCellUpdated(rowIndex, ACTIONS_COL);
                }
            } else {
                _revertValues.put(entry.name, entry.value);
                fireTableCellUpdated(rowIndex, ACTIONS_COL);
            }
            entry.value = newValue;
            break;

        case ACTIONS_COL:
            // the new value will be an action indicating what has happened
            int action = ((Integer) newValue).intValue();
            switch (action) {
            case ACTION_REVERT:
                entry.value = _revertValues.remove(entry.name);
                fireTableCellUpdated(rowIndex, VALUE_COL);
                break;

            case ACTION_DELETE:
                deleteRow(rowIndex, entry.name);
                break;
            }
            break;

        case INFO_COL:
            // implemented here for ease, but only specific subclasses allow setting this field
            entry.info = (String) newValue;
            break;

        case REQUIRED_COL:
            // implemented here for ease, but only specific subclasses allow setting this field
            entry.optional = !((Boolean) newValue).booleanValue();
            break;
        }
    }

    /**
     * Extract the String names of the entries in this model.
     */
    protected abstract List<String> initFields (CreatingDataPack pack);

    /**
     * Get the entry for the specified row.
     */
    protected abstract CreatingDataPack.AbstractEntry getEntry (int rowIndex);

    /**
     * Delete the specified row.
     */
    protected void deleteRow (int rowIndex, String entryName)
    {
        throw new RuntimeException("Should be overridden in classes that set _deleteRows=true");
    }

    /** Do we allow the deletion of rows? */
    protected boolean _deleteRows;

    /** Do we block reverting? */
    protected boolean _blockRevert;

    /** The pack we're editing. */
    protected CreatingDataPack _pack;

    /** A List of the names to be used in the rows. */
    protected List<String> _fields;

    /** A mapping of datum name to the original value, only if the value was changed. */
    protected HashMap<String,Object> _revertValues = new HashMap<String,Object>();
}
