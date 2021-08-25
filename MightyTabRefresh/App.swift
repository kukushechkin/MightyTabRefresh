//
//  AppDelegate.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 10.7.2021.
//

import SwiftUI
import AppKit

// required to close app on last window close
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

struct ContentView: View {
    @EnvironmentObject private var extensionController: ExtensionViewModel

    var body: some View {
        VStack {
            ControlsView()
                .environmentObject(self.extensionController)
            SettingsView(extensionSettings: self.$extensionController.settings)
        }
    }
}

@main
struct MightyTabRefreshApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
