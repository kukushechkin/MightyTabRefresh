//
//  AppDelegate.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 10.7.2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var extensionController: ExtensionController
    
    var body: some View {
        VStack {
            Spacer()
            if self.extensionController.enabled {
                Text("Extension is activated, everything is fine")
            } else {
                Button("Activate Safari Extension") {
                    self.extensionController.openSafariPrefs()
                }
            }
            Spacer()
            Button("Refresh") {
                self.extensionController.updateState()
            }
            .padding()
            Spacer()
            Button("Update settigns") {
                self.extensionController.updateSettings()
            }
            .padding()

        }
    }
}

@main
struct MightyTabRefreshApp: App {
    @StateObject var extensionController = ExtensionController()
    
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
