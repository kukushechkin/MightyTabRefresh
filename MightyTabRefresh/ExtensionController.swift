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
import ExtensionSettings

internal class ExtensionController: ObservableObject {
    private let log = OSLog(subsystem: "com.kukushechkin.MightyRefresh", category: "ExtensionController")
    private let statusRefreshQueue = DispatchQueue(label: "com.kukushechkin.MightyRefresh.extensionCheckQueue")
    
    private let extensionBundleIdentifier = "com.kukushechkin.MightyTabRefresh.Extension"
    
    private let lastKnownExtensionStateKey = "lastKnownExtensionState"
    private let defaults = UserDefaults(suiteName: "com.kukushechkin.MightyRefresh.ExtensionController")

    @Published var enabled: Bool
    @Published var settings: ExtensionSettings
    
    internal init() {
        self.enabled = defaults?.bool(forKey: self.lastKnownExtensionStateKey) ?? false
        // Hardcode some test settings
        self.settings = ExtensionSettings(rules: [
            Rule(enabled: true, pattern: "apple.com", refreshInterval: 1.0),
            Rule(enabled: true, pattern: "ya.ru", refreshInterval: 5.0),
        ])
        self.updateState()

    }
    
    internal func updateState() {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: extensionBundleIdentifier) { (state, error) in
            guard let unwrappedState = state, error == nil else {
                self.enabled = false
                os_log(.error, log: self.log, "Safari App Extension is not enabled: %d, %s", state?.isEnabled ?? false, error?.localizedDescription ?? "")
                return
            }
            
            os_log(.info, log: self.log, "New Safari App Extension state: %d", unwrappedState.isEnabled)
            DispatchQueue.main.async {
                self.enabled = unwrappedState.isEnabled
            }
        }
    }
    
    internal func openSafariPrefs() {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier) { error in
            // close app?
        }
    }
    
    internal func updateSettings() {
        // TODO: log rules
        os_log(.info, log: self.log, "Will send settings to Safari App Extension")
        guard let encodedSettings = try? self.settings.encode() else {
            os_log(.error, log: self.log, "Failed to encode settings to json")
            return
        }
        SFSafariApplication.dispatchMessage(withName: ExtensionSettings.settingsMessageName,
                                            toExtensionWithIdentifier: self.extensionBundleIdentifier,
                                            userInfo: [ExtensionSettings.settingsMessageKey: encodedSettings]) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                os_log(.error, log: self.log, "Error sending settings to Safari App Extension: %s", error.localizedDescription)
            }
        }
    }
}
