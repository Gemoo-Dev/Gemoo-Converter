import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

T.TextField {

    id: control

    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
                   || Math.max(contentWidth, placeholder.implicitWidth) + leftPadding + rightPadding

    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    padding: 8
    topPadding: padding - 7
    rightPadding: padding - 4
    bottomPadding: padding - 5

    color: control.palette.text
    selectionColor:GlobalConfig.highlight
    selectedTextColor: GlobalConfig.selectedTextColor
    placeholderTextColor: Color.transparent(control.color, 0.5)
    verticalAlignment: TextInput.AlignVCenter
    font:GlobalConfig.font
    selectByMouse: true
    PlaceholderText {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)

        text: control.placeholderText
        font: control.font
        color: control.placeholderTextColor
        verticalAlignment: control.verticalAlignment
        visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
        elide: Text.ElideRight
        renderType: control.renderType
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 28
        radius: 5
        border.width:  1
        color: control.palette.base
        border.color: control.activeFocus ?GlobalConfig.highlight: GlobalConfig.borderColor
    }
}

// import QtQuick 2.15
// import QtQuick.Controls 2.15

// TextField {
//     font: GlobalConfig.fontItem.font
//     padding: 3
//     implicitHeight: 30
// }
