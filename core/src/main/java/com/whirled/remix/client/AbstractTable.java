//
// $Id$

package com.whirled.remix.client;

import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;

import java.awt.event.ActionEvent;

import javax.swing.AbstractAction;
import javax.swing.AbstractCellEditor;
import javax.swing.JButton;
import javax.swing.JPanel;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.UIManager;

import javax.swing.border.Border;
import javax.swing.border.EmptyBorder;

import javax.swing.table.TableCellEditor;
import javax.swing.table.TableCellRenderer;
import javax.swing.table.TableColumnModel;

import com.samskivert.swing.GroupLayout;
import com.samskivert.util.StringUtil;

import com.whirled.remix.data.CreatingDataPack;

public abstract class AbstractTable extends JTable
{
    public AbstractTable (CreatingDataPack pack)
    {
        AbstractModel model = createModel(pack);
        setModel(model);

        TableColumnModel colModel = getColumnModel();
        for (int col = 0; col < AbstractModel.COLUMN_COUNT; col++) {
            colModel.getColumn(col).setPreferredWidth(model.getPreferredColumnWidth(col));
        }

        Dimension d = _infoRenderer.getComponent().getPreferredSize();
        setRowHeight(d.height);
        colModel.getColumn(AbstractModel.INFO_COL).setPreferredWidth(d.width);
    }

//    @Override
//    public Dimension getPreferredSize ()
//    {
//        Dimension d = super.getPreferredSize();
//        System.err.println("super.pref: " + d);
//        d.width = Math.max(d.width, 1650);
//        return d;
//    }

    @Override
    public TableCellRenderer getCellRenderer (int row, int column)
    {
        switch (convertColumnIndexToModel(column)) {
        default:
            return super.getCellRenderer(row, column);

        case AbstractModel.TYPE_COL:
            return getDefaultRenderer(String.class);

        case AbstractModel.INFO_COL:
            return _infoRenderer;

        case AbstractModel.ACTIONS_COL:
            return _actionRenderer;

        case AbstractModel.REQUIRED_COL:
            return getDefaultRenderer(Boolean.class);
        }
    }

    @Override
    public TableCellEditor getCellEditor (int row, int column)
    {
        switch (convertColumnIndexToModel(column)) {
        case AbstractModel.ACTIONS_COL:
            return _actionRenderer;

        case AbstractModel.INFO_COL:
            return _infoEditor;

        default:
            return super.getCellEditor(row, column);
        }
    }

    /**
     * Create the table model to use.
     */
    protected abstract AbstractModel createModel (CreatingDataPack pack);

    // TODO... will this work?
    protected static class ActionCellRenderer extends AbstractCellEditor
        implements TableCellRenderer, TableCellEditor
    {
        public ActionCellRenderer ()
        {
            _comp = GroupLayout.makeButtonBox(GroupLayout.CENTER);
            _comp.add(_view = new JButton(new AbstractAction("View") {
                public void actionPerformed (ActionEvent event) {
                    _returnValue = AbstractModel.ACTION_VIEW;
                    stopCellEditing();
                }
            }));
            _view.setBackground(Color.GREEN);
            _comp.add(_revert = new JButton(new AbstractAction("Revert") {
                public void actionPerformed (ActionEvent event) {
                    _returnValue = AbstractModel.ACTION_REVERT;
                    stopCellEditing();
                }
            }));
            _revert.setBackground(Color.YELLOW);
            _comp.add(_delete = new JButton(new AbstractAction("Delete") {
                public void actionPerformed (ActionEvent event) {
                    _returnValue = AbstractModel.ACTION_DELETE;
                    stopCellEditing();
                }
            }));
            _delete.setBackground(Color.RED);
        }

        // from CellEditor
        public Object getCellEditorValue ()
        {
            return _returnValue;
        }

        // from TableCellEditor
        public Component getTableCellEditorComponent (
            JTable table, Object value, boolean isSelected, int row, int col)
        {
            _returnValue = 0;
            setup(value);
            return _comp;
        }

        // from TableCellRenderer
        public Component getTableCellRendererComponent (
            JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int col)
        {
            setup(value);
            return _comp;
        }

        /**
         * Set up the action buttons according to the 
         */
        protected void setup (Object value)
        {
            int flags = ((Integer) value).intValue();
            _revert.setVisible((flags & AbstractModel.ACTION_SHOW_REVERT) != 0);
            _revert.setEnabled((flags & AbstractModel.ACTION_REVERT) != 0);
            _delete.setVisible((flags & AbstractModel.ACTION_DELETE) != 0);
            _view.setVisible((flags & AbstractModel.ACTION_VIEW) != 0);
        }

        /** The value to return when this editor is done "editing". */
        protected int _returnValue = 0;

        protected JPanel _comp;

        protected JButton _view;

        protected JButton _revert;

        protected JButton _delete;
    }

    protected static class InfoCellRenderer extends AbstractCellEditor
        implements TableCellRenderer, TableCellEditor
    {
        public InfoCellRenderer ()
        {
            _textArea = new JTextArea(2, 40);
        }

        /**
         * Provide easy access to the component so that the table can query size..
         */
        public JTextArea getComponent ()
        {
            return _textArea;
        }

        // from CellEditor
        public Object getCellEditorValue ()
        {
            String txt = _textArea.getText();
            if (StringUtil.isBlank(txt)) {
                // set to null if no actual description was entered
                txt = null;
            }
            return txt;
        }

        // from TableCellEditor
        public Component getTableCellEditorComponent (
            JTable table, Object value, boolean isSelected, int row, int col)
        {
            return getTableCellRendererComponent(table, value, isSelected, true, row, col);
        }

        // from TableCellRenderer
        public Component getTableCellRendererComponent (
            JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int col)
        {
            // set up the value
            String txt = (String) value;
            if (StringUtil.isBlank(txt)) {
                // setting null to the TextArea makes it not update its value...
                txt = "";
            }
            _textArea.setText(txt);

            // set up colors
            if (isSelected) {
                _textArea.setForeground(table.getSelectionForeground());
                _textArea.setBackground(table.getSelectionBackground());
            } else {
                _textArea.setForeground(table.getForeground());
                _textArea.setBackground(table.getBackground());
            }

            // font
            _textArea.setFont(table.getFont());

            // borders
            if (hasFocus) {
                Border border = null;
                if (isSelected) {
                    border = UIManager.getBorder("Table.focusSelectedCellHighlightBorder");
                }
                if (border == null) {
                    border = UIManager.getBorder("Table.focusCellHighlightBorder");
                }
                _textArea.setBorder(border);

            } else {
                _textArea.setBorder(NO_BORDER);
            }

            return _textArea;
        }

        protected static final Border NO_BORDER = new EmptyBorder(1, 1, 1, 1);

        protected JTextArea _textArea;
    }

    protected ActionCellRenderer _actionRenderer = new ActionCellRenderer();

    protected InfoCellRenderer _infoRenderer = new InfoCellRenderer();
    protected InfoCellRenderer _infoEditor = new InfoCellRenderer();
}
