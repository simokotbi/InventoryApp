pragma Singleton
import QtQuick 2.15
import Themestyles 1.0
import App 1.0

QtObject {
    id:typography
    readonly property string fontFamily: "Arial"
    readonly property int headingSize: 22
    readonly property int bodySize: 16
}
