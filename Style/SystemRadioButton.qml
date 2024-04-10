import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

T.RadioButton {
    id: control
    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             Math.max(contentItem.implicitHeight,
                                      indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset
    padding: 2
    spacing: 2
    font.pixelSize:  15
    property alias backgroundColor: backgroundRect.color
    property color textColor: control.palette.windowText

    background:Rectangle{
        id:backgroundRect
    }
    // keep in sync with RadioDelegate.qml (shared RadioIndicator.qml was removed for performance reasons)
    indicator: Rectangle {
        implicitWidth: 12
        implicitHeight: 12
        x: text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) :
                  control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2

        radius: width / 2
        color: control.down ? control.palette.light : control.palette.base
        border.width: control.visualFocus ? 2 : 1
        border.color: control.visualFocus ? control.palette.highlight : control.palette.mid
        Rectangle {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 10
            height: 10
            radius: width / 2
            color: control.palette.text
            visible: control.checked
        }
    }

    contentItem: CheckLabel {
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing +control.indicator.x: 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0
        text: control.text
        font: control.font
        color:control.textColor
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
