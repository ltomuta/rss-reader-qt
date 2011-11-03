import QtQuick 1.0
import com.nokia.meego 1.0
import "Util.js" as Util

Page {
    id: container

    property string fontName: "Helvetica"
    property int fontSize: 10
    property color fontColor: "black"
    property string itemTitle
    property string itemDescription
    property string itemUrl
    property string itemImageUrl
    property int scrollBarWidth: 8
    property int margin: 4
    property int spacing: 4

    width: 480
    height: 854

    Flickable {
        id: flicker
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: buttonPart.top
        flickableDirection: "VerticalFlick"
        clip: true

        contentWidth: parent.width
        contentHeight: titleText.height + textPart.y + textPart.height + container.margin*4

        Text {
            id: titleText
            text: appState.selectedFeedItemTitle
            anchors {
                margins: container.margin*2
                top: parent.top
                left: parent.left
                right: parent.right
            }
            font {
                family: container.fontName
                pointSize: container.fontSize
                bold: true
            }
            color: container.fontColor
            wrapMode: Text.Wrap
            textFormat: Text.RichText
        }

        Grid {
            id: grid

            property bool inLandscape: container.width > container.height
            property int cellWidth: inLandscape && imagePart.visible ? width/2 : width
            onCellWidthChanged: console.log("CellWidth: " + cellWidth)

            rows: inLandscape ? 1 : 2
            columns: inLandscape ? 2 : 1
            spacing: container.spacing
            anchors {
                top: titleText.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: container.margin*2
            }

            Image {
                id: imagePart
                width: grid.cellWidth
                fillMode: Image.PreserveAspectFit
                source: itemImageUrl
                visible: itemImageUrl != ""
                onStatusChanged: {
                    Util.log("image status "+status)
                }
            }

            Text {
                id: textPart
                width: grid.cellWidth
                font {
                    family: container.fontName
                    pointSize: container.fontSize
                }
                color: container.fontColor
                text: itemDescription
                wrapMode: Text.Wrap
                textFormat: Text.RichText
            }
        }
    }

    ScrollBar {
        scrollArea: flicker;
        width: container.scrollBarWidth;
        anchors.top: flicker.top;
        anchors.right: flicker.right;
        anchors.bottom: flicker.bottom
    }

    Button {
        id: buttonPart

        visible: itemUrl.length > 0
        width: parent.width
        height: 61
        anchors {
            bottom: parent.bottom
            bottomMargin: container.margin*3
            left: parent.left
            right: parent.right
        }
        font {
            family: container.fontName
            pointSize: container.fontSize
        }

        text: qsTr("Read the full article")

        onClicked: {
            Qt.openUrlExternally(itemUrl)
        }
    }
}
