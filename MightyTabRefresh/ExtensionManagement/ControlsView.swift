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
                Text("Extension is activated, everything is fine")
            } else {
                HStack {
                    Text("Extension is not active")
                    Button("Activate Safari Extension") {
                        self.extensionController.openSafariPreferences()
                    }
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
