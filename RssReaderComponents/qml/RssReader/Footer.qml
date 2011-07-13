import QtQuick 1.0
import com.nokia.symbian 1.0

Item {
    id: container

    signal settingsButtonClicked

    width: 360
    height: 80

    Button {
        id: settings_button
        width: 86
        height: 86
        text: ""
        scale: 0.8*parent.height/86
        onClicked: container.settingsButtonClicked()
        anchors {
            verticalCenter: parent.verticalCenter
            right: container.right
            margins: 8
        }

        iconSource: visual.theme.images.settingsIcon

//        Image {
//            source: visual.theme.images.settingsIcon
//            anchors.fill: parent
//            anchors.margins: 8
//            fillMode: Image.PreserveAspectFit
//            smooth: true
//        }
    }
}
