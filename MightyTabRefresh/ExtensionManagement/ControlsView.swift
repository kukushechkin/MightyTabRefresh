//
//  ControlsView.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 20.7.2021.
//

import Foundation
import SwiftUI
import ExtensionSettings

struct ControlsView: View {
    @EnvironmentObject  var extensionController: ExtensionViewModel
    
    var body: some View {
        HStack {
            Spacer()
            if self.extensionController.enabled {
                Text("Extension is active, everything is fine, enjoy refreshing tabs")
                    .foregroundColor(Color(NSColor.disabledControlTextColor))

            } else {
                HStack {
                    Text("Extension is not active. Please, enable extension in Safari preferences")
                    .foregroundColor(Color.red)
                    Button(action: {
                        self.extensionController.updateState()
                        self.extensionController.updateSettings()
                        self.extensionController.openSafariPreferences()
                    }) { Label("", systemImage: "safari") }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .padding()
        .toolbar {
            Button(action: {
                self.extensionController.updateState()
                self.extensionController.updateSettings()
                self.extensionController.openSafariPreferences()
            }) { Label("", systemImage: "safari") }
        }
    }
}

struct ControlsView_Previews: PreviewProvider {
    static let enabledExtension = ExtensionViewModel(extensionController: ExtensionControllerMock(enabled: true))
    static let disabledExtension = ExtensionViewModel(extensionController: ExtensionControllerMock(enabled: false))
    
    static var previews: some View {
        VStack {
            Group {
                ControlsView()
                    .environmentObject(self.enabledExtension)
                ControlsView()
                    .environmentObject(self.disabledExtension)
            }
            .environment(\.colorScheme, .light)
            
            Divider()
            
            Group {
                ControlsView()
                    .environmentObject(self.enabledExtension)
                ControlsView()
                    .environmentObject(self.disabledExtension)
            }
            .environment(\.colorScheme, .dark)
        }
    }
}
