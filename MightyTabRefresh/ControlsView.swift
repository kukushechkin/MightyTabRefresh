//
//  ControlsView.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 20.7.2021.
//

import Foundation
import SwiftUI

struct ControlsView: View {
    @EnvironmentObject private var extensionController: ExtensionController
    
    var body: some View {
        HStack {
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
