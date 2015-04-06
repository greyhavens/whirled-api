//
// $Id$

package com.whirled.remix.client;

import java.awt.Component;

import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;

import javax.swing.DefaultCellEditor;
import javax.swing.JCheckBox;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.UIManager;

import javax.swing.border.Border;
import javax.swing.border.EmptyBorder;

import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.TableCellEditor;
import javax.swing.table.TableCellRenderer;
import com.whirled.remix.data.CreatingDataPack;

public class RemixingDataTable extends AbstractTable
{
    public RemixingDataTable (CreatingDataPack pack)
    {
        super(pack);
    }

    @Override
    public TableCellRenderer getCellRenderer (int row, int column)
    {
        switch (convertColumnIndexToModel(column)) {
        default:
            return super.getCellRenderer(row, column);

        case RemixingDataModel.VALUE_COL:
        case RemixingDataModel.DEFAULT_COL:
            CreatingDataPack.DataType type = (CreatingDataPack.DataType)
                getModel().getValueAt(row, RemixingDataModel.TYPE_COL);
            switch (type) {
            default:
                return super.getCellRenderer(row, column);

            case NUMBER:
                return _numberRenderer;

            case ARRAY:
                return _arrayRenderer;

            case BOOLEAN:
                return _booleanEditor;

            case POINT:
                return _pointRenderer;

            case RECTANGLE:
                return _rectangleRenderer;
            }
        }
    }

    @Override
    public TableCellEditor getCellEditor (int row, int column)
    {
        switch (convertColumnIndexToModel(column)) {
        default:
            return super.getCellEditor(row, column);

        case RemixingDataModel.VALUE_COL:
        case RemixingDataModel.DEFAULT_COL:
            CreatingDataPack.DataType type = (CreatingDataPack.DataType)
                getModel().getValueAt(row, RemixingDataModel.TYPE_COL);
            switch (type) {
            default:
                return super.getCellEditor(row, column);

            case NUMBER:
                return _numberEditor;

            case ARRAY:
                return _arrayEditor;

            case BOOLEAN:
                return _booleanEditor;

            case POINT:
                return _pointEditor;

            case RECTANGLE:
                return _rectangleEditor;
            }
        }
    }

    // from AbstractTable
    protected AbstractModel createModel (CreatingDataPack pack)
    {
        return new RemixingDataModel(pack);
    }

    protected static class DataCellEditor extends DefaultCellEditor
    {
        public DataCellEditor ()
        {
            super(new JTextField());
        }

        @Override
        public Component getTableCellEditorComponent (
            JTable table, Object value, boolean isSelected, int row, int col)
        {
            _origValue = value;
            if (value != null) {
                value = formatValue(value);
            }
            return super.getTableCellEditorComponent(table, value, isSelected, row, col);
        }

        @Override
        public Object getCellEditorValue ()
        {
            try {
                return parseValue((String) super.getCellEditorValue());
            } catch (Exception e) {
                return _origValue;
            }
        }

        /**
         * Format the objecty value into a String.
         */
        protected String formatValue (Object value)
        {
            return String.valueOf(value);
        }

        /**
         * Parse the stringy value.
         */
        protected Object parseValue (String value)
            throws Exception
        {
            return value;
        }

        /** The original value. */
        protected Object _origValue;
    }

    protected static class NumberCellRenderer extends DefaultTableCellRenderer
    {
        @Override
        public void setValue (Object value)
        {
            super.setValue(NumberCellEditor.format(value));
        }
    }

    protected static class NumberCellEditor extends DataCellEditor
    {
        public static String format (Object value)
        {
            if (value == null) {
                return null;
            }

            Double d = (Double) value;
            return d.toString();
        }

        protected String formatValue (Object value)
        {
            return format(value);
        }

        protected Object parseValue (String value)
            throws Exception
        {
            return Double.parseDouble(value);
        }
    }

    protected static class ArrayCellRenderer extends DefaultTableCellRenderer
    {
        @Override
        public void setValue (Object value)
        {
            super.setValue(ArrayCellEditor.format(value));
        }
    }

    protected static class ArrayCellEditor extends DataCellEditor
    {
        public static String format (Object value)
        {
            if (value == null) {
                return null;
            }

            String[] array = (String[]) value;
            StringBuilder buf = new StringBuilder();
            for (int ii = 0; ii < array.length; ii++) {
                if (ii > 0) {
                    buf.append(' ');
                }
                buf.append('[').append(array[ii]).append(']');
            }
            return buf.toString();
        }

        @Override
        protected String formatValue (Object value)
        {
            return format(value);
        }

        @Override
        protected Object parseValue (String value)
            throws Exception
        {
            if (value.length() > 1) {
                value = value.substring(1, value.length() - 1);
            }
            return value.split("\\]\\ \\[");
        }
    }

    protected static class PointCellRenderer extends DefaultTableCellRenderer
    {
        @Override
        public void setValue (Object value)
        {
            super.setValue(PointCellEditor.format(value));
        }
    }

    protected static class PointCellEditor extends DataCellEditor
    {
        public static String format (Object value)
        {
            if (value == null) {
                return null;
            }

            Point2D.Double p = (Point2D.Double) value;
            return p.getX() + ", " + p.getY();
        }

        protected String formatValue (Object value)
        {
            return format(value);
        }

        protected Object parseValue (String value)
            throws Exception
        {
            String[] arr = value.split(",");
            if (arr.length != 2) {
                throw new Exception();
            }
            return new Point2D.Double(Double.parseDouble(arr[0].trim()),
                Double.parseDouble(arr[1].trim()));
        }
    }

    protected static class RectangleCellRenderer extends DefaultTableCellRenderer
    {
        @Override
        public void setValue (Object value)
        {
            super.setValue(RectangleCellEditor.format(value));
        }
    }

    protected static class RectangleCellEditor extends DataCellEditor
    {
        public static String format (Object value)
        {
            if (value == null) {
                return null;
            }

            Rectangle2D.Double r = (Rectangle2D.Double) value;
            return r.getX() + ", " + r.getY() + ", " + r.getWidth() + ", " + r.getHeight();
        }

        protected String formatValue (Object value)
        {
            return format(value);
        }

        protected Object parseValue (String value)
            throws Exception
        {
            String[] arr = value.split(",");
            if (arr.length != 4) {
                throw new Exception();
            }
            return new Rectangle2D.Double(Double.parseDouble(arr[0].trim()),
                Double.parseDouble(arr[1].trim()),
                Double.parseDouble(arr[2].trim()),
                Double.parseDouble(arr[3].trim()));
        }
    }

    protected static class BooleanEditor extends DefaultCellEditor
        implements TableCellRenderer
    {
        public BooleanEditor () {
            super(new JCheckBox());
            _box = (JCheckBox) getComponent();
            _box.setHorizontalAlignment(JCheckBox.CENTER);
        }

        public Component getTableCellRendererComponent (
            JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column)
        {
            if (isSelected) {
                _box.setForeground(table.getSelectionForeground());
                _box.setBackground(table.getSelectionBackground());
            } else {
                _box.setForeground(table.getForeground());
                _box.setBackground(table.getBackground());
            }
            if (hasFocus) {
                _box.setBorder(UIManager.getBorder("Table.focusCellHighlightBorder"));
            } else {
                _box.setBorder(_noFocusBorder);
            }

            _box.setText(String.valueOf(value));
            _box.setBorderPainted(true);
            return super.getTableCellEditorComponent(table, value, isSelected, row, column);
        }

        @Override
        public Component getTableCellEditorComponent (
            JTable table, Object value, boolean isSelected, int row, int column)
        {
            getTableCellRendererComponent(table, value, false, false, row, column);
            _box.setBorderPainted(false);
            return _box;
        }

// TODO: possibly make it harder to start editing. Right now a stray click toggles the value!
//        @Override
//        public boolean isCellEditable (EventObject anEvent)
//        {
//            System.err.println("an event is " + anEvent);
//            return super.isCellEditable(anEvent);
//        }

        protected JCheckBox _box;

        protected Border _noFocusBorder = new EmptyBorder(1, 1, 1, 1);
    }

    protected NumberCellRenderer _numberRenderer = new NumberCellRenderer();
    protected NumberCellEditor _numberEditor = new NumberCellEditor();

    protected ArrayCellRenderer _arrayRenderer = new ArrayCellRenderer();
    protected ArrayCellEditor _arrayEditor = new ArrayCellEditor();

    protected PointCellRenderer _pointRenderer = new PointCellRenderer();
    protected PointCellEditor _pointEditor = new PointCellEditor();

    protected RectangleCellRenderer _rectangleRenderer = new RectangleCellRenderer();
    protected RectangleCellEditor _rectangleEditor = new RectangleCellEditor();

    protected BooleanEditor _booleanEditor = new BooleanEditor();
}
