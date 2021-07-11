//
//  Model.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 10.7.2021.
//

import Foundation
import SwiftUI
import Combine
import SafariServices
import os.log

internal class ExtensionController: ObservableObject {
    private let log = OSLog(subsystem: "com.kukushechkin.MightyRefresh", category: "ExtensionController")
    private let statusRefreshQueue = DispatchQueue(label: "com.kukushechkin.MightyRefresh.extensionCheckQueue")
    
    private let extensionBundleIdentifier = "com.kukushechkin.MightyTabRefresh.Extension"
    
    private let lastKnownExtensionStateKey = "lastKnownExtensionState"
    private let defaults = UserDefaults(suiteName: "com.kukushechkin.MightyRefresh.ExtensionController")

    @Published var enabled: Bool
    
    internal init() {
        self.enabled = defaults?.bool(forKey: self.lastKnownExtensionStateKey) ?? false
        self.updateState()

    }
    
    internal func updateState() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionBundleIdentifier) { (state, error) in
            guard let state = state, error == nil else {
                self.enabled = false
                os_log(.error, log: self.log, "Safari App Extension is not enabled: %d, %s", state?.isEnabled ?? false, error?.localizedDescription ?? "")
                return
            }
            
            os_log(.info, log: self.log, "New Safari App Extension state: %d", state.isEnabled)
            DispatchQueue.main.async {
                self.enabled = state.isEnabled
            }
        }
    }
    
    internal func openSafariPrefs() {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier) { error in
            // close app?
        }
    }
    
}
