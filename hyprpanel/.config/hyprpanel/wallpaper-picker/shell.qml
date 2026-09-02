// Wallpaper picker — Quickshell.  Run: qs -p ~/.config/hyprpanel/wallpaper-picker
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string favPath: home + "/.config/hyprpanel/wallpaper-favs"
    readonly property string thumbDir: home + "/.cache/wallpaper-thumbs"
    readonly property string poolA: home + "/Pictures/wallpapers/images"
    readonly property string poolB: home + "/Pictures/wallpapers"

    property var allPaths: []
    property var favNames: ({})
    property string tab: Quickshell.env("WP_TAB") === "favs" ? "favs" : "all"

    function baseName(p) { return p.substring(p.lastIndexOf("/") + 1) }
    function isFav(p) { return favNames[baseName(p)] === true }
    function thumbFor(p) { return "file://" + thumbDir + "/" + Qt.md5(p) + ".png" }

    readonly property var shown: tab === "favs"
        ? allPaths.filter(p => isFav(p))
        : allPaths

    // ---------- favourites ----------
    Process {
        id: favReader
        command: ["cat", root.favPath]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = {}
                text.split("\n").forEach(l => { if (l.trim()) m[l.trim()] = true })
                root.favNames = m
            }
        }
    }
    Process { id: favWriter }
    function toggleFav(p) {
        const n = baseName(p)
        const m = Object.assign({}, favNames)
        if (m[n]) delete m[n]; else m[n] = true
        favNames = m
        const q = JSON.stringify(n), f = JSON.stringify(favPath)
        favWriter.command = ["sh", "-c",
            `grep -qxF ${q} ${f} 2>/dev/null ` +
            `&& grep -vxF ${q} ${f} > ${f}.t && mv ${f}.t ${f} ` +
            `|| printf '%s\\n' ${q} >> ${f}`]
        favWriter.running = true
    }

    // ---------- apply ----------
    Process { id: setter }
    function apply(p) {
        setter.command = ["hyprpanel", "setWallpaper", p]
        setter.running = true
        Qt.quit()
    }

    // ---------- wallpaper list ----------
    FolderListModel {
        id: folder
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.PNG", "*.JPEG"]
        showDirs: false
        sortField: FolderListModel.Name
        onStatusChanged: if (status === FolderListModel.Ready) root.rebuild()
        onCountChanged: root.rebuild()
    }
    Process {
        id: poolPick
        command: ["sh", "-c",
            `[ -n "$(ls -A ${JSON.stringify(root.poolA)} 2>/dev/null)" ] && echo A || echo B`]
        stdout: StdioCollector {
            onStreamFinished: folder.folder =
                "file://" + (text.trim() === "A" ? root.poolA : root.poolB)
        }
    }
    function rebuild() {
        const arr = []
        for (let i = 0; i < folder.count; i++)
            arr.push(folder.get(i, "fileUrl").toString().replace(/^file:\/\//, ""))
        allPaths = arr
    }

    Component.onCompleted: { poolPick.running = true; favReader.running = true }

    // ---------- window ----------
    PanelWindow {
        id: win
        color: "#00000000"
        anchors { top: true; bottom: true; left: true; right: true }
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "wallpaper-picker"

        Rectangle {
            anchors.fill: parent
            color: "#00000073"
            MouseArea { anchors.fill: parent; onClicked: Qt.quit() }
        }

        Rectangle {
            id: panel
            anchors.centerIn: parent
            width: Math.min(parent.width - 120, 1360)
            height: Math.min(parent.height - 120, 840)
            radius: 20
            color: "#2e3440"
            border.width: 1
            border.color: "#434c5e"

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10
                    Repeater {
                        model: [{ key: "all", label: "All" },
                                { key: "favs", label: "★  Favourites" }]
                        delegate: Rectangle {
                            radius: height / 2
                            implicitHeight: 42
                            implicitWidth: tl.implicitWidth + 44
                            color: root.tab === modelData.key ? "#88c0d0" : "#3b4252"
                            Behavior on color { ColorAnimation { duration: 110 } }
                            Text {
                                id: tl
                                anchors.centerIn: parent
                                text: modelData.label
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                color: root.tab === modelData.key ? "#2e3440" : "#d8dee9"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.tab = modelData.key
                            }
                        }
                    }
                }

                GridView {
                    id: grid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    readonly property int cols: Math.max(2, Math.floor(width / 330))
                    cellWidth: Math.floor(width / cols)
                    cellHeight: Math.floor(cellWidth * 10 / 16)
                    cacheBuffer: 1200
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.shown

                    delegate: Item {
                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            id: card
                            anchors.fill: parent
                            anchors.margins: 7
                            radius: 16
                            clip: true
                            color: "#363d4d"
                            border.width: root.isFav(modelData) ? 3 : 0
                            border.color: "#bf616a"

                            Image {
                                id: pic
                                anchors.fill: parent
                                source: root.thumbFor(modelData)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                sourceSize.width: 520
                                opacity: status === Image.Ready ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 160 } }
                            }
                            MultiEffect {
                                anchors.fill: pic
                                source: pic
                                visible: hh.hovered && pic.status === Image.Ready
                                blurEnabled: true
                                blur: 1.0
                                blurMax: 40
                            }
                            // dim + bottom gradient so controls read against any image
                            Rectangle {
                                anchors.fill: parent
                                opacity: hh.hovered ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 120 } }
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#1c222dbb" }
                                    GradientStop { position: 0.55; color: "#1c222d55" }
                                    GradientStop { position: 1.0; color: "#1c222de6" }
                                }
                            }

                            // ---- hover controls: two matching round buttons ----
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 14
                                spacing: 12
                                opacity: hh.hovered ? 1 : 0
                                y: hh.hovered ? 0 : 10
                                Behavior on opacity { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                                Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                                component PillButton: Rectangle {
                                    property alias hovered: pbMa.containsMouse
                                    property string glyph: ""
                                    property color activeColor: "#88c0d0"
                                    property color restColor: "#d8dee9"
                                    signal activated()
                                    width: 46; height: 46; radius: 23
                                    color: pbMa.containsMouse ? activeColor : "#2e3440"
                                    border.width: pbMa.containsMouse ? 0 : 1
                                    border.color: "#5c667a"
                                    Behavior on color { ColorAnimation { duration: 90 } }
                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        shadowEnabled: true; shadowColor: "#000000"
                                        shadowOpacity: 0.45; shadowBlur: 0.5; shadowVerticalOffset: 3
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.glyph
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 19
                                        color: parent.hovered ? "#1a1b26" : parent.restColor
                                    }
                                    MouseArea {
                                        id: pbMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: parent.activated()
                                    }
                                }

                                // favourite
                                PillButton {
                                    glyph: root.isFav(modelData) ? "♥" : "♡"
                                    activeColor: "#e06c75"
                                    restColor: root.isFav(modelData) ? "#e06c75" : "#d8dee9"
                                    onActivated: root.toggleFav(modelData)
                                }
                                // apply
                                PillButton {
                                    glyph: ""   // nf check
                                    activeColor: "#88c0d0"
                                    onActivated: root.apply(modelData)
                                }
                            }
                            HoverHandler { id: hh }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: grid.count === 0
                        color: "#7b88a1"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                        text: root.tab === "favs"
                            ? "no favourites yet — hover a wallpaper and tap ♡"
                            : "no wallpapers in ~/Pictures/wallpapers"
                    }
                }
            }

            Shortcut { sequences: ["Escape"]; onActivated: Qt.quit() }
        }
    }
}
