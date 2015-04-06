//
// $Id$

package com.whirled.remix.client;

import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Font;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;

import com.samskivert.swing.GroupLayout;
import com.samskivert.swing.JInternalDialog;
import com.samskivert.swing.Spacer;

import com.samskivert.swing.event.DocumentAdapter;

import com.whirled.remix.data.CreatingDataPack;

public abstract class AbstractAddDialog extends JInternalDialog
{
    public AbstractAddDialog (JComponent host, CreatingDataPack pack, Action popupAction)
    {
        super(host);
        _pack = pack;
        _popupAction = popupAction;

        setClosable(true);
        setResizable(true);

        // create the buttons to close us..
        JPanel butbox = GroupLayout.makeButtonBox(GroupLayout.CENTER);
        butbox.add(new JButton(_okAction = new AbstractAction("Ok") {
            public void actionPerformed (ActionEvent event) {
                createRow(_name.getText().trim(), _type.getSelectedItem(), _desc.getText().trim());
                dispose();
            }
        }));
        _okAction.setEnabled(false);
        butbox.add(new JButton(new AbstractAction("Cancel") {
            public void actionPerformed (ActionEvent event) {
                dispose();
            }
        }));

        // make a panel to hold everything
        JPanel panel = GroupLayout.makeVBox();
        panel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));
        // allow it to be populated by a subclass
        createContent(panel);
        validateData();
        // add the buttons
        panel.add(butbox);
        add(new JScrollPane(panel));

        pack();
        showDialog();
    }

    @Override
    public void dispose ()
    {
        super.dispose();
        _popupAction.setEnabled(true);
    }

    /**
     * Called to add the components of the add dialog.
     */
    protected void createContent (JPanel panel)
    {
        // configure layout constraints..
        GridBagConstraints c1 = new GridBagConstraints();
        c1.gridx = 0;
        c1.anchor = GridBagConstraints.NORTHWEST;

        GridBagConstraints c2 = new GridBagConstraints();
        c2.gridx = 1;
        c2.gridwidth = GridBagConstraints.REMAINDER;
        c2.anchor = GridBagConstraints.NORTHWEST;

        GridBagConstraints cHelp = new GridBagConstraints();
        cHelp.gridx = 0;
        cHelp.gridwidth = GridBagConstraints.REMAINDER;
        cHelp.anchor = GridBagConstraints.NORTHWEST;
        cHelp.fill = GridBagConstraints.BOTH;

        GridBagConstraints cSpacer = new GridBagConstraints();
        cSpacer.gridx = 0;
        cSpacer.gridwidth = GridBagConstraints.REMAINDER;
        cSpacer.anchor = GridBagConstraints.NORTHWEST;

        JPanel grid = new JPanel(new GridBagLayout());
        panel.add(grid);

        // add the widgets
        grid.add(new JLabel("Type:"), c1);
        grid.add(_type = new JComboBox(), c2);

        grid.add(new Spacer(1, 1), c1);
        grid.add(_typeLabel = new JLabel(), c2);
        grid.add(createHelpText(getTypeHelp()), cHelp);
        grid.add(new Spacer(20, 20), cSpacer);

        grid.add(_nameLabel = new JLabel("Name:"), c1);
        grid.add(_name = new JTextField(12), c2);
        grid.add(createHelpText("The name used to access this data."), cHelp);
        grid.add(new Spacer(20, 20), cSpacer);

        grid.add(_descLabel = new JLabel("Description:"), c1);
        grid.add(_desc = new JTextField(20), c2);
        grid.add(createHelpText("A short human-readable description of the field, to aid remixers."),
            cHelp);

        // configure the behavior of the widgets
        DocumentAdapter docValidate = new DocumentAdapter() {
            @Override
            public void documentChanged () {
                validateData();
            }
        };
        _name.getDocument().addDocumentListener(docValidate);
        _desc.getDocument().addDocumentListener(docValidate);

        _type.setEditable(false);
        _type.addActionListener(new ActionListener() {
            public void actionPerformed (ActionEvent event) {
                CreatingDataPack.AbstractType type =
                    (CreatingDataPack.AbstractType) _type.getSelectedItem();
                _typeLabel.setText((type != null) ? type.getDescription() : "");
                validateData();
            }
        });
    }

    protected JTextArea createHelpText (String text)
    {
        JTextArea t = new JTextArea();
        t.setEditable(false);
        t.setFocusable(false);
        t.setLineWrap(true);
        t.setWrapStyleWord(true);
        t.setText(text);

        Font f = t.getFont();
        t.setFont(f.deriveFont((float) 12));

        return t;
    }

    protected void validateData ()
    {
        _okAction.setEnabled(areFieldsValid());
    }

    /**
     * Get the help text for the 'type' selector.
     */
    protected abstract String getTypeHelp ();

    /**
     * Are all the configured fields valid?
     */
    protected abstract boolean areFieldsValid ();

    /**
     * Actually create the new rom of data, after OK is pressed.
     */
    protected abstract void createRow (String name, Object type, String desc);

    protected CreatingDataPack _pack;

    protected Action _okAction;

    protected Action _popupAction;

    protected JTextField _name;
    protected JComboBox _type;
    protected JTextField _desc;
    protected JLabel _typeLabel;
    protected JLabel _nameLabel;
    protected JLabel _descLabel;
}
