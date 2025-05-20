import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components"

Rectangle {
    id: root
    color: "white"

    signal formSubmitted(var formData)
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.defaultMargin
        spacing: Theme.defaultSpacing * 2

        Text {
            text: "User Information"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeHeading
            color: Theme.textColor
        }

        CustomInput {
            id: fullNameInput
            label: "Full Name"
            placeholderText: "Enter your full name"
            Layout.fillWidth: true
            onAccepted: dobInput.forceActiveFocus()
        }

        CustomInput {
            id: dobInput
            label: "Date of Birth"
            placeholderText: "YYYY-MM-DD"
            Layout.fillWidth: true
            onAccepted: departmentCombo.forceActiveFocus()
        }

        ComboBox {
            id: departmentCombo
            Layout.fillWidth: true
            model: ["Sales", "Marketing", "Development"]
            
            background: Rectangle {
                color: "white"
                border.color: parent.pressed ? Theme.primaryColor : "#DEDEDE"
                border.width: parent.pressed ? 2 : 1
                radius: Theme.cornerRadius
            }
        }

        CheckBox {
            id: newsletterCheck
            text: "Subscribe to Newsletter"
            font.family: Theme.fontFamily
        }

        CustomButton {
            text: "Submit"
            Layout.fillWidth: true
            onClicked: {
                const formData = {
                    fullName: fullNameInput.text,
                    dob: dobInput.text,
                    department: departmentCombo.currentText,
                    newsletter: newsletterCheck.checked
                };
                root.formSubmitted(formData);
                
                // Clear form after submission
                fullNameInput.text = "";
                dobInput.text = "";
                departmentCombo.currentIndex = 0;
                newsletterCheck.checked = false;
                fullNameInput.forceActiveFocus();
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: {
        fullNameInput.forceActiveFocus()
    }
}