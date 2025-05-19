import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"
import "../components"

Rectangle {
    color: "white"
    
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
        }

        CustomInput {
            id: dobInput
            label: "Date of Birth"
            placeholderText: "YYYY-MM-DD"
            Layout.fillWidth: true
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

        Text {
            id: successText
            visible: false
            color: Theme.successColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMedium
            Layout.fillWidth: true
        }

        CustomButton {
            text: "Submit"
            Layout.fillWidth: true
            onClicked: {
                successText.text = "Form submitted successfully!";
                successText.visible = true;
                console.log("Form Data:", JSON.stringify({
                    fullName: fullNameInput.text,
                    dob: dobInput.text,
                    department: departmentCombo.currentText,
                    newsletter: newsletterCheck.checked
                }, null, 2));
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}