//
//  wbec_ios_appApp.swift
//  wbec-ios-app
//
//  Created by Andreas Miketta on 21.02.22.
//

import SwiftUI

@main
struct wbec_ios_appApp: App {
    init(){
        UITabBar.appearance().barTintColor = UIColor(Color("BackGroundColor"))
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    ContentView()
                    
                }.tabItem {
                    Image(systemName: "bolt.car")
                    Text("Wallbox")
                }
                NavigationView {
                    ConfigurationView().navigationTitle("Settings")
                }.tabItem {
                    Image(systemName: "pencil.circle")
                    Text("Settings")
                }
            }.accentColor(.white)
        }
    }
}
