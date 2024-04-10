import QtQuick 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Controls.Universal 2.15

T.ComboBox {
    id:control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight:28
    // Math.max(implicitBackgroundHeight + topInset + bottomInset,
    //                          implicitContentHeight + topPadding + bottomPadding,
    //                          implicitIndicatorHeight + topPadding + bottomPadding)


    //checked选中状态，down按下状态，hovered悬停状态
    property color backgroundTheme: "#A0F0F0F0"
    //下拉框背景色
    property color backgroundColor: control.down
                                    ? Qt.darker(backgroundTheme)
                                    : control.hovered
                                      ? Qt.lighter(backgroundTheme)
                                      : backgroundTheme
    //边框颜色
    property color borderColor: GlobalConfig.borderColor
    //item高亮颜色
    property color itemHighlightColor: Qt.darker(backgroundTheme)
    //item普通颜色
    property color itemNormalColor: "#A0F0F0F0"//backgroundTheme
    //每个item的高度
    property int itemHeight: height
    //每个item文本的左右padding
    property int itemPadding: 10
    //下拉按钮颜色
    //property color indicatorColor: "white"
    //下拉按钮左右距离
    property int indicatorPadding: 1
    //下拉按钮图标
    property url indicatorSource: "qrc:/qt-project.org/imports/QtQuick/Controls.2/images/double-arrow.png"
    //圆角
    property int radius: 0
    //最多显示的item个数
    property int showCount: 10
    //文字颜色
    property color textColor: "#333333"
    //model数据左侧附加的文字
    property string textLeft: ""
    //model数据右侧附加的文字
    property string textRight: ""

    property  Component itemDelegate:null
    padding: 0
    // topPadding: padding - 7
    // rightPadding: padding - 4
    // bottomPadding: padding - 5
    hoverEnabled: true
    currentIndex: -1
    // spacing: 0
    // leftPadding: padding
    // rightPadding: padding + indicator.width + spacing

    font:GlobalConfig.font

    //各item
    delegate: ItemDelegate {
        id: box_item
        height: control.itemHeight
        //Popup如果有padding，这里要减掉2*pop.padding
        width: control.width-scrollBar.width
        padding: 0
        Component{
            id:defaultDelegate
            Text {
                text: (control.textRole?
                           (Array.isArray(control.model)
                            ? delegateModelData[control.textRole]
                            : delegateModel[control.textRole])
                         : delegateModelData)

                color: control.textColor
                leftPadding: control.itemPadding
                rightPadding: control.itemPadding
                // font.family: control.font.family
                font: control.font
                elide: Text.ElideRight

             //   renderType: Text.NativeRendering
                verticalAlignment: Text.AlignVCenter
            }
        }

        contentItem:Loader{
            property var  delegateModel:model
            property var  delegateIndex:index
            sourceComponent: itemDelegate==undefined?defaultDelegate:itemDelegate
        }

        hoverEnabled: control.hoverEnabled

        background: Rectangle{
            radius: control.radius
            color:control.currentIndex === index? "#C0C0F0":
                                                  (control.highlightedIndex === index)
                                                  ? control.itemHighlightColor
                                                  : control.itemNormalColor
            opacity:hovered?1:0.8

            //item底部的线
            Rectangle{
                height: 1
                width: parent.width-2*control.radius
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                color: Qt.lighter(control.itemNormalColor)
            }
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                if(control.currentIndex===index){
                    control.currentIndex=-1;
                }
                control.currentIndex=index;
                popup.close();
            }
        }
    }
    // box显示item
    contentItem: T.TextField{
        id:textField
        //control的leftPadding会挤过来，不要设置control的padding
        text: control.editable
              ? control.editText
              : (control.textLeft+control.displayText+control.textRight)
       // font: control.font
        color: control.textColor
        verticalAlignment: Text.AlignVCenter

        //默认鼠标选取文本设置为false
        selectByMouse: true
        //选中文本的颜色
        selectedTextColor:GlobalConfig.selectedTextColor
        //选中文本背景色
        selectionColor: GlobalConfig.selectionColor
        clip: true
        //renderType: Text.NativeRendering
        enabled: control.editable
        autoScroll: control.editable
        readOnly: control.down
        inputMethodHints: control.inputMethodHints
        validator: control.validator
        //renderType: Text.NativeRendering
         // renderType: Text.QtRendering
        padding: 8
        topPadding: padding - 7
        rightPadding: padding - 4
        bottomPadding: padding - 5

    }

    //box框背景
    background: Rectangle {
        // implicitWidth: control.implicitWidth
        implicitWidth: 200
        implicitHeight:28
        radius: 5
        color: control.palette.base
        border.color:   control.activeFocus ?GlobalConfig.highlight: GlobalConfig.borderColor
        border.width:  1
    }

    //弹出框
    popup: T.Popup {
        id:popup
        //默认向下弹出，如果距离不够，y会自动调整（）
        y: control.height
        width: control.width
        //根据showCount来设置最多显示item个数
        implicitHeight: control.delegateModel
                        ?((control.delegateModel.count<showCount)
                          ?contentItem.implicitHeight
                          :control.showCount*control.itemHeight)+2
                        :0
        //用于边框留的padding
        padding: 1
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            //按行滚动SnapToItem ;像素移动SnapPosition
            snapMode: ListView.SnapToItem
            ScrollBar.vertical: SystemScrollBar {
                id: scrollBar
                // onActiveChanged: {
                //     console.log("onActiveChanged========================")
                //     active = true;
                // }
                // Component.onCompleted: {
                //     //                    scrollBar.handle.color = "yellow"
                //     //                    scrollBar.active = true;
                //     //                    scrollBar.handle.width = 10;
                //     console.log("Component.onCompleted========================")
                // }
            }

        }

        //弹出框背景（只有border显示出来了，其余部分被delegate背景遮挡）
        background: Rectangle{
            border.width: 1
            border.color:GlobalConfig.borderColor
            //color: Qt.lighter(themeColor)
            radius:5
        }
    }
    indicator: ColorImage {
        id:colorImage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 1
        width: height
        // sourceSize.height: height-4
        fillMode:Image.Stretch
        source: "qrc:/qt-project.org/imports/QtQuick/Controls.2/Universal/images/downarrow.png"
        rotation:control.popup.opened?180:0
        Rectangle {
            visible: !control.popup.opened
            z: -1
            y:1
            anchors.left: parent.left
            height: parent.height-2
            width:1
            color:  control.activeFocus ?GlobalConfig.highlight: GlobalConfig.borderColor
        }
        Rectangle {
            visible: control.popup.opened
            z: -1
            y:1
            anchors.left: parent.right
            height: parent.height-2
            width:1
            color:  control.activeFocus ?GlobalConfig.highlight: GlobalConfig.borderColor

        }
    }

    function getIndexFromText(text)
    {
        for(var i=0;i<model.count;i++)
        {
            if(model.get(i)[textRole].toUpperCase()==text.toUpperCase())
            {
              return i;
            }
        }
        return -1;
    }
}

