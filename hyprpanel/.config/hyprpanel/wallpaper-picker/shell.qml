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
    readonly property string poolA: home + "/Pictures/wallpapers/images"
    readonly property string poolB: home + "/Pictures/wallpapers"

    property var allPaths: []
    property var favNames: ({})
    property string tab: Quickshell.env("WP_TAB") === "favs" ? "favs" : "all"

    function baseName(p) { return p.substring(p.lastIndexOf("/") + 1) }
    function isFav(p) { return favNames[baseName(p)] === true }

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

        // click the dimmed backdrop to dismiss
        Rectangle {
            anchors.fill: parent
            color: "#66000000"
            MouseArea { anchors.fill: parent; onClicked: Qt.quit() }
        }

        Rectangle {
            id: panel
            anchors.centerIn: parent
            width: Math.min(parent.width - 120, 1320)
            height: Math.min(parent.height - 120, 820)
            radius: 18
            color: "#2e3440"
            border.width: 2
            border.color: "#3b4252"
            // swallow clicks so they don't hit the backdrop
            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8
                    Repeater {
                        model: [{ key: "all", label: "All" },
                                { key: "favs", label: "★ Favourites" }]
                        delegate: Rectangle {
                            radius: height / 2
                            implicitHeight: 40
                            implicitWidth: tl.implicitWidth + 40
                            color: root.tab === modelData.key ? "#88c0d0" : "#3b4252"
                            Text {
                                id: tl
                                anchors.centerIn: parent
                                text: modelData.label
                                font.pixelSize: 15
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
                    readonly property int cols: Math.max(1, Math.floor(width / 320))
                    cellWidth: Math.floor(width / cols)
                    cellHeight: Math.floor(cellWidth * 9 / 16)
                    cacheBuffer: 800
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.shown

                    delegate: Item {
                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 6
                            radius: 14
                            clip: true
                            color: "#3b4252"
                            border.width: 3
                            border.color: root.isFav(modelData) ? "#bf616a" : "transparent"

                            Image {
                                id: pic
                                anchors.fill: parent
                                source: "file://" + modelData
                                sourceSize.width: 560
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: false
                            }
                            MultiEffect {
                                anchors.fill: pic
                                source: pic
                                visible: hh.hovered
                                blurEnabled: true
                                blur: 1.0
                                blurMax: 48
                            }
                            Rectangle {
                                anchors.fill: parent
                                color: "#5c000000"
                                opacity: hh.hovered ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 110 } }
                            }
                            Row {
                                anchors.centerIn: parent
                                spacing: 12
                                opacity: hh.hovered ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 110 } }

                                Rectangle {
                                    radius: height / 2
                                    height: 46; width: 58
                                    color: hMa.containsMouse ? "#88c0d0"
                                           : root.isFav(modelData) ? "#bf616a" : "#2e3440ee"
                                    border.width: 2; border.color: "#d8dee930"
                                    Text {
                                        anchors.centerIn: parent
                                        text: root.isFav(modelData) ? "♥" : "♡"
                                        font.pixelSize: 19; color: "#eceff4"
                                    }
                                    MouseArea {
                                        id: hMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.toggleFav(modelData)
                                    }
                                }
                                Rectangle {
                                    radius: height / 2
                                    height: 46; width: sl.implicitWidth + 44
                                    color: sMa.containsMouse ? "#88c0d0" : "#2e3440ee"
                                    border.width: 2; border.color: "#d8dee930"
                                    Text {
                                        id: sl
                                        anchors.centerIn: parent
                                        text: "Set"; font.pixelSize: 16
                                        color: sMa.containsMouse ? "#2e3440" : "#eceff4"
                                    }
                                    MouseArea {
                                        id: sMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.apply(modelData)
                                    }
                                }
                            }
                            HoverHandler { id: hh }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: grid.count === 0
                        color: "#7b88a1"
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
