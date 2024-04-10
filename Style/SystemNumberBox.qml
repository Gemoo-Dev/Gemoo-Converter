/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls 2 module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15

T.SpinBox {
    id: control
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentItem.implicitWidth + 16 +
                            up.implicitIndicatorWidth +
                            down.implicitIndicatorWidth)
    implicitHeight: Math.max(implicitContentHeight + topPadding + bottomPadding,
                             implicitBackgroundHeight,
                             up.implicitIndicatorHeight,
                             down.implicitIndicatorHeight)
    padding: 8
    topPadding: padding - 4
    leftPadding: padding + (control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0))
    rightPadding: padding - 4 + (control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0))
    bottomPadding: padding - 5
    editable:true
    property color borderColor: GlobalConfig.borderColor
    validator: IntValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }
    font: GlobalConfig.font
    contentItem: TextInput {
        text: control.displayText
        font: control.font
        color: control.palette.text
        selectionColor:GlobalConfig.highlight
        selectedTextColor:GlobalConfig.selectedTextColor
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        selectByMouse: true
        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints
       // anchors.fill: parent
    }/*MouseArea{

        onWheel: {
            //  if(wheel.modifiers& Qt.ControlModifier)
            {
                if(wheel.angleDelta.y > 0)
                    control.value += 1
                else
                    control.value  -= 1
            }

        }
    }*/

    up.indicator: Item {
        implicitWidth: 25
        height: parent.height + 4
        y: -2
        x: control.mirrored ? 0 : parent.width - width

        Rectangle {
            anchors.left: parent.left
            y: 4
            width:1
            height: parent.height-control.topPadding-control.bottomPadding
            radius:0
            color: hovered? GlobalConfig.highlight: GlobalConfig.borderColor //control.borderColor
            visible:true// control.up.pressed || control.up.hovered
            opacity:1// control.activeFocus && !control.up.pressed ? 0.4 : 1.0
            //radius: 5
        }

        ColorImage {
            anchors.centerIn: parent
            anchors.margins:2
            color: !hovered? control.borderColor:  GlobalConfig.highlight
            source: "qrc:/qt-project.org/imports/QtQuick/Controls.2/Universal/images/" + (control.mirrored ? "left" : "right") + "arrow.png"
        }
    }

    down.indicator: Item {
        implicitWidth: 25
        height: parent.height + 4
        y: -2
        x: control.mirrored ? parent.width - width : 0
        Rectangle {
            anchors.right: parent.right
            y: 4
            width:1
            //  x:control.topPadding+4
            height: parent.height-control.topPadding-control.bottomPadding
            radius:0
            // border.color: control.borderColor
            // border.width: 1
            color: hovered? GlobalConfig.highlight: GlobalConfig.borderColor //control.borderColor
            visible:true// control.down.pressed || control.down.hovered
            opacity: 1//control.activeFocus && !control.down.pressed ? 0.4 : 1.0
        }
        ColorImage {
            anchors.centerIn: parent
            anchors.margins: 2
            // x: (parent.width - width) / 2
            // y: (parent.height - height) / 2
            color:!hovered? control.borderColor:  GlobalConfig.highlight
            source: "qrc:/qt-project.org/imports/QtQuick/Controls.2/Universal/images/" + (control.mirrored ? "right" : "left") + "arrow.png"
        }
    }

    background: Rectangle {
        implicitWidth: 60 + 25 // TextControlThemeMinWidth - 4 (border)
        implicitHeight: 28 // TextControlThemeMinHeight - 4 (border)
        border.width: 1 // TextControlBorderThemeThickness
        border.color: control.activeFocus ?GlobalConfig.highlight: GlobalConfig.borderColor
        color:control.palette.base
        radius: 5
    }
}
