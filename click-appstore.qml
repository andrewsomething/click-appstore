/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Click App Store - An app for viewing the available Ubuntu Touch apps    *
 * Copyright (C) 2013 Michael Spencer <sonrisesoftware@gmail.com>          *
 *                                                                         *
 * This program is free software: you can redistribute it and/or modify    *
 * it under the terms of the GNU General Public License as published by    *
 * the Free Software Foundation, either version 3 of the License, or       *
 * (at your option) any later version.                                     *
 *                                                                         *
 * This program is distributed in the hope that it will be useful,         *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            *
 * GNU General Public License for more details.                            *
 *                                                                         *
 * You should have received a copy of the GNU General Public License       *
 * along with this program. If not, see <http://www.gnu.org/licenses/>.    *
 ***************************************************************************/
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "ui"
import "components/htttplib.js" as Http

/*!
    \brief MainView with Tabs element.
           First Tab has a single Label and
           second Tab has a single ToolbarAction.
*/

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename 
    applicationName: "click-apps"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true
    
    width: units.gu(100)
    height: units.gu(75)

    PageStack {
        id: pageStack

        Component.onCompleted: pageStack.push(allApps)

    }

    Page {
        id: allApps
        title: "Available Apps"
        visible: false

        ListView {
            anchors.fill: parent
            model: appsModel
            delegate: ListItem.Subtitled {
                icon: icon_url
                text: title
                subText: name
                onClicked: {
                    Http.get("https://search.apps.ubuntu.com/api/v1/package/" + name, [], loadDetails)
                    pageStack.push(appDetails, {title: title})
                }
            }
        }
    }

    Page {
        id: appDetails
        visible: false

        ListView {
            anchors.fill: parent
            anchors.margins: units.gu(2)
            model: detailsModel
            delegate: Column {
                width: parent.width
                anchors.centerIn: parent
                spacing: units.gu(2)

                Image {
                    source: icon_url
                }

                Label {
                    text: "Description:"
                    fontSize: "large"
                }

                Item {
                    width: parent.width
                    height: body.paintedHeight + units.gu(2)

                    UbuntuShape {
                        color: "white"
                        anchors.fill: parent

                        Label {
                            id: body
                            width: parent.width - units.gu(2)
                            anchors.centerIn: parent
                            text: model.description
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }
                    }
                }

                Label {
                    text: "Version: " + version
                }

                Label {
                    text: "Website: <a href='" + website + "'>" + website + "</a>"
                    onLinkActivated: {
                      Qt.openUrlExternally(website)
                    }
                }

                Label {
                    text: "License: " + license
                }

                Label {
                    text: "Screenshot:"
                }

                Image {
                    width: 0.666667*parent.width
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    source: screenshot_url
                }
            }
        }
    }

    ListModel {
        id: appsModel
    }

    ListModel {
        id: detailsModel
    }

    Component.onCompleted: Http.get("https://search.apps.ubuntu.com/api/v1/search?q=", [], loadApps)

    function loadApps(response) {
        var json = JSON.parse(response)
        for (var i = 0; i < json.length; i++) {
            appsModel.append(json[i])
        }
    }

    function loadDetails(response) {
        detailsModel.clear()
        var json = JSON.parse(response)
        detailsModel.append(json)
    }
}
