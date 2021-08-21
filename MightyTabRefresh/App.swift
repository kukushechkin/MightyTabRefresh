//
//  AppDelegate.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 10.7.2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var extensionController: ExtensionViewModel
    
    var body: some View {
        VStack {
            SettingsView(extensionSettings: self.$extensionController.settings)
            Spacer()
            ControlsView()
                .environmentObject(self.extensionController)
        }
    }
}

@main
struct MightyTabRefreshApp: App {
    @StateObject var extensionController = ExtensionViewModel(extensionController: ExtensionController(extensionIdentifier: "com.kukushechkin.MightyTabRefresh.Extension"))
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900,
                       maxWidth: .infinity,
                       minHeight: 500,
                       maxHeight: .infinity)
                .environmentObject(self.extensionController)
        }
    }
}
