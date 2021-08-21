//
//  ExtensionController.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 21.8.2021.
//

import Foundation
import SafariServices
import os.log

enum ExtensionState {
    case enabled
    case disabled
}

protocol ExtensionControllerProtocol {
    func getState(_ callback: @escaping (ExtensionState) -> Void)
    func openSafariPreferences()
    func sendSettingsToExtension(name: String, settings: [String: Any])
}

class ExtensionController: ExtensionControllerProtocol {
    private let log = OSLog(subsystem: "com.kukushechkin.MightyTabRefresh", category: "ExtensionController")
    private let extensionIdentifier: String
    
    init(extensionIdentifier: String) {
        self.extensionIdentifier = extensionIdentifier
    }
    
    func getState(_ callback: @escaping (ExtensionState) -> Void) {
        SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: self.extensionIdentifier) { [weak self] (state, error) in
            guard let self = self else { return }
            guard let unwrappedState = state, error == nil else {
                os_log(.error, log: self.log, "Safari App Extension %{public}s is not enabled, error: %{public}s", self.extensionIdentifier, error?.localizedDescription ?? "")
                callback(.disabled)
                return
            }
            
            os_log(.info, log: self.log, "New Safari App Extension %{public}s state: %d", self.extensionIdentifier, unwrappedState.isEnabled)
            callback(unwrappedState.isEnabled ? .enabled : .disabled)
        }
    }
    
    func openSafariPreferences() {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: self.extensionIdentifier) { error in
            // Should there be a callback to close the app?
        }
    }
    
    func sendSettingsToExtension(name: String, settings: [String : Any]) {
        // This switches focus to Safari => cannot be used
        SFSafariApplication.dispatchMessage(withName: name,
                                            toExtensionWithIdentifier: self.extensionIdentifier,
                                            userInfo: settings) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                os_log(.error, log: self.log, "Error sending settings to Safari App Extension %{public}s: %{public}s", self.extensionIdentifier, error.localizedDescription)
            }
        }
    }
    
    
}

