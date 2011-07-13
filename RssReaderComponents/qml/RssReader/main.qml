import QtQuick 1.0
import com.nokia.symbian 1.0
import "Util.js" as Util

// Follow http://doc.qt.nokia.com/4.7/qml-coding-conventions.html
Window {
    id: mainWindow

    anchors.centerIn: parent    
    width: 360
    height: 640

    Rectangle {
        anchors.fill: parent
        color: visual.theme.applicationBackgroundColor
    }

//    color: visual.theme.applicationBackgroundColor

    // We start out showing the splash screen
    state: "showingSplashScreen"

    // TODO: Change the Visual stuff into use here!
    Loader {
        id: visual
        property alias theme: visual.item
        source: "Visual.qml"
    }

    // Properties.
    AppStateVars {
        id: appState
    }

    // Wait indicator is also not visible by default, only when mainWindow.loading === true
    WaitIndicator {
        id: waitIndicator
        anchors.centerIn: contentPane
        width: contentPane.width
        height: contentPane.height
        z: 120
        show: appState.loading
    }

    // Splash screen is full screen but visible only at the start
    SplashScreen {
        id: splashScreen
        anchors.fill: parent
        // Put splash screen on top of everything. Otherwise you would need to lay it out as the last objects
        // in the layout for it to be on top of all other objects. But with z-property we get same results
        z: 100
        // Splash screen timeout
        timeout: visual.theme.splashTimeout
        image: "gfx/splash_screen.png"
        // When splash screen times out, move to default state
        onSplashTimeout: {
            appState.currentViewName = "categoryView";
            Util.log("Splash screen finished")
        }
    }

    // All views have a title bar
    TitleBar {
        id: titleBar
//        enabled: !viewSwitcher.running
        enabled: true

        // Anchors titlebar to left,top and right. Then set height
        // Use grouping if possible.
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        backButtonSource: visual.theme.images.backButton
        backButtonPressedSource: visual.theme.images.backButtonPressed
        exitButtonSource: visual.theme.images.exitButton
        exitButtonPressedSource: visual.theme.images.exitButtonPressed
        exitButtonVisible: visual.theme.exitButtonVisible

        fontBold: true
        fontName: visual.theme.titleBarFont
        fontSize: visual.theme.titleBarFontSize
        fontColor: visual.theme.titlebarFontColor
        color: visual.theme.titleBarBackgroundColor
        height: visual.theme.titleBarHeight
        text: appState.currentTitle
        iconSource: visual.theme.images.rssLogo
        showingBackButton: appState.showBackButton
        onBackButtonClicked: {
            Util.log("Back-button clicked. Came from view: " + viewName);
            if (viewName === "feedView") {
                appState.fromLeft = true;
                appState.currentViewName = "categoryView";
            } else if (viewName === "feedItemView") {
                appState.fromLeft = true;
                appState.currentViewName = "feedView";
            } else if (viewName === "discoveryView") {
                appState.fromLeft = false;
                appState.currentViewName = "categoryView";
            } else if (viewName === "settingsView") {
                appState.fromLeft = false;
                appState.currentViewName = "categoryView";
            }
        }
        onExitButtonClicked: {
            Util.exitApp("Exit-button clicked");
        }        
    }

    // PageStack for navigation between the views
    PageStack {
        id: pageStack

        clip: true
        anchors {
            top: titleBar.bottom
            left: parent.left
            right: parent.right
            bottom: footer.top
            margins: 8
        }
    }

    // This item will contain the views that we switch between
    Item {
        id: contentPane

        clip: true
        anchors {
            top: titleBar.bottom
            left: parent.left
            right: parent.right
            bottom: footer.top
            margins: 8
        }

//        // View switcher component, handles the view switching and animation
//        ViewSwitcher {
//            id: viewSwitcher
//            // Rooted in contentPane
//            root: contentPane
//            // Start from feedListView
//            currentView: categoryView
//        }

        // Our views inside the contentPane

        // Settings view
        SettingsView {
            id: settingsView
            anchors.fill: parent
            fontName: visual.theme.settingsViewFont
            fontSize: visual.theme.settingsViewFontSize
            fontColor: visual.theme.settingsViewFontColor
            onThemeChanged: {
                visual.source = theme+".qml";                
            }
        }

        // Discovery view to add more subscriptions
        DiscoveryView {
            id: discoveryView
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            // Must use width and not anchor to left&right for left/right animations to work
            width:  parent.width
            // The views that are not visible should be set to 0 opacity or visible: false
            fontName: visual.theme.discoveryViewFont
            fontSize: visual.theme.discoveryViewFontSize
            fontColor: visual.theme.discoveryViewFontColor
        }

        // Main view containing your subscriptions
        CategoryView {
            id: categoryView
            anchors {
                top: parent.top
                bottom: parent.bottom
            }

            width: parent.width
            headerItemFontName: visual.theme.categoryViewHeaderItemFont
            headerItemFontSize: visual.theme.categoryViewHeaderItemFontSize
            headerItemFontColor: visual.theme.categoryViewHeaderItemFontColor

            subItemFontName: visual.theme.categoryViewSubItemFont
            subItemFontSize: visual.theme.categoryViewSubItemFontSize
            subItemFontColor: visual.theme.categoryViewSubItemFontColor

            onFeedSelected: {
                Util.log("Selected feed: " + feedName)
                appState.selectedFeedTitle = feedName;
                appState.fromLeft = false;
                appState.currentViewName = "feedView";
            }
            onDiscoverFromCategory: {                
                Util.log("Discover from " + category
                                         + ", url:" + categoryView.selectedCategoryUrl);
                // Set the discovery view to show the proper category:                
                discoveryView.categoryTitle = category                
                appState.selectedFeedTitle = categoryView.expandedCategoryTitle                                
                appState.fromLeft = true;
                appState.currentViewName = "discoveryView";
                appState.currentTitle = "Manage "+category+" Feeds"
            }
        }

        // Feed view showing selected feed's items
        FeedView {
            id: feedView
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width:  parent.width
            scrollBarWidth: visual.theme.scrollBarWidth
            fontName: visual.theme.feedViewFont
            fontSize: visual.theme.feedViewFontSize
            fontColor: visual.theme.feedViewFontColor
            feedName: categoryView.selectedCategoryTitle
            feedUrl: categoryView.selectedCategoryUrl
            onFeedItemSelected: {
                Util.log("Selected feed item");
                appState.selectedFeedItemTitle = title;
                appState.fromLeft = false;
                appState.currentViewName = "feedItemView";
            }
        }

        FeedItemView {
            id: feedItemView
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width:  parent.width
            scrollBarWidth: visual.theme.scrollBarWidth
            fontName: visual.theme.feedItemViewFont
            fontSize: visual.theme.feedItemViewFontSize
            fontColor: visual.theme.feedItemViewFontColor

            itemTitle: feedView.itemTitle
            itemDescription: feedView.itemDescription
            itemUrl: feedView.itemUrl
            itemImageUrl: feedView.itemImageUrl
        }

        BorderImage {
            id: frame
            source: visual.theme.images.frame
            border { left: 8; top: 8; right: 8; bottom: 8 }
            width: contentPane.width
            // Adjust the background frame a bit when in feedView or feedItemView to give some
            // space for the button there.
            height: appState.currentViewName == "feedItemView" || appState.currentViewName == "feedView"
                    ? contentPane.height - 75  : contentPane.height
            anchors { top: contentPane.top; left: contentPane.left }
        }
    }

    Footer {
        id: footer
        height: visual.theme.footerHeight
        property bool show: false
        state: show ? "visible" : "hidden"
        anchors {
            left: parent.left
            right: parent.right
        }
        states: [
            State {
                name: "visible"
                AnchorChanges { target: footer; anchors.bottom: parent.bottom; anchors.top: undefined }
            },
            State {
                name: "hidden"
                AnchorChanges { target: footer; anchors.bottom: undefined; anchors.top: parent.bottom }
            }
        ]

        transitions: Transition { AnchorAnimation { duration: 400;  easing.type: Easing.InOutQuad } }
        onSettingsButtonClicked: {
            appState.fromLeft = true
            appState.currentViewName = "settingsView"
        }
    }

//    Component.onCompleted: {
//        console.log("Main.qml completed, pushing CategoryView into PageStack");
//        pageStack.push(categoryView);
//    }

    // States


    // Default state is implicit, all other states are defined here
    states: [
        State {
            name: "showingSplashScreen"
            PropertyChanges {
                target: splashScreen
                // Show the splash screen. It's internal implementation will
                // take care of smooth transitioning.
                show: true
            }
        },
        State {
            name: "showingDiscoveryView"
            when: appState.currentViewName === "discoveryView";
            PropertyChanges {
                // Set all state variable changes to appState
                target: appState
                showBackButton: true;
                //currentTitle: qsTr("Manage "+""+" feeds")
            }
            PropertyChanges {
                target: titleBar
                fontSize: visual.theme.titleBarSmallestFontSize
            }
            // Animate the view switch with viewSwitcher
            StateChangeScript { script: pageStack.replace(discoveryView); }
        },
        State {
            name: "showingCategoryView"
            // Move to this state when currentView name is set to categoryView
            when: appState.currentViewName === "categoryView";
            PropertyChanges {
                // Set all state variable changes to appState
                target: appState
                showBackButton: false;
                currentTitle: qsTr("RSS Reader");
            }
            PropertyChanges { target: footer; show: true }
            // Animate the view switch with viewSwitcher
            StateChangeScript { script: console.log("Changing Page to: CategoryView"); }
            StateChangeScript { script: pageStack.replace(categoryView); }
        },
        State {
            name: "showingFeedView"
            when: appState.currentViewName === "feedView";
            PropertyChanges {
                // Set all state variable changes to appState
                target: appState
                showBackButton: true
                currentTitle: appState.selectedFeedTitle
            }
            PropertyChanges {
                target: titleBar
                fontSize: visual.theme.titleBarSmallerFontSize
            }
            // Animate the view switch with viewSwitcher
            StateChangeScript { script: console.log("Changing Page to: FeedView"); }
            StateChangeScript { script: pageStack.replace(feedView); }
        },
        State {
            name: "showingFeedItemView"
            when: appState.currentViewName === "feedItemView";
            PropertyChanges {
                // Set all state variable changes to appState
                target: appState
                showBackButton: true
                currentTitle: appState.selectedFeedTitle                
            }
            PropertyChanges {
                target: titleBar
                fontSize: visual.theme.titleBarSmallerFontSize
            }
            // Animate the view switch with viewSwitcher
            StateChangeScript { script: console.log("Changing Page to: FeedItemView"); }
            StateChangeScript { script: pageStack.replace(feedItemView); }
        },
        State {
            name: "showingSettingsView"
            when: appState.currentViewName === "settingsView";
            PropertyChanges {
                // Set all state variable changes to appState
                target: appState
                showBackButton: true
                currentTitle: qsTr("Settings")
            }
            // Animate the view switch with viewSwitcher
            StateChangeScript { script: console.log("Changing Page to: SettingsView"); }
            StateChangeScript { script: pageStack.replace(settingsView); }
        }
    ]
}

