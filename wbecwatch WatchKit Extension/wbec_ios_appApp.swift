//
//  wbec_ios_appApp.swift
//  wbecwatch WatchKit Extension
//
//  Created by Andreas Miketta on 21.02.22.
//

import SwiftUI

@main
struct wbec_ios_appApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
