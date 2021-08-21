//
//  ExtensionViewModel.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 10.7.2021.
//

import Foundation
import SwiftUI
import Combine
import os.log
import ExtensionSettings

internal class ExtensionViewModel: ObservableObject {
    private let log = OSLog(subsystem: "com.kukushechkin.MightyTabRefresh", category: "ExtensionViewModel")
    private let statusRefreshQueue = DispatchQueue(label: "com.kukushechkin.MightyTabRefresh.extensionCheckQueue")
//    private let schedule: Cancellable?
    
    private let lastKnownExtensionStateKey = "lastKnownExtensionState"
    private let lastKnownExtensionSettingsKey = "lastKnownExtensionSettings"
    private let defaults = UserDefaults(suiteName: "AC5986BBE6.com.kukushechkin.MightyTabRefresh.appGroup")

    let extensionController: ExtensionControllerProtocol
    
    @Published var enabled: Bool
    @Published var settings: ExtensionSettings
        
    internal init(extensionController: ExtensionControllerProtocol) {
        self.extensionController = extensionController
        self.enabled = defaults?.bool(forKey: self.lastKnownExtensionStateKey) ?? false
            
        if let persistentData = defaults?.object(forKey: self.lastKnownExtensionSettingsKey),
           let settings = ExtensionSettings(from: persistentData) {
            self.settings = settings
        } else {
            // Hardcode some test settings if there is none
            self.settings = ExtensionSettings(rules: [
                Rule(enabled: true, pattern: "apple.com", refreshInterval: 1.0),
                Rule(enabled: true, pattern: "ya.ru", refreshInterval: 5.0),
                Rule(enabled: false, pattern: "google.com", refreshInterval: 60.0),
            ])
        }
        
        self.updateState()
        // self.updateSettings()
        
//        self.schedule = self.statusRefreshQueue.schedule(after: DispatchQueue.SchedulerTimeType(DispatchTime(uptimeNanoseconds: 0)),
//                                                         interval: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: 1.0),
//                                                         tolerance: 0.1,
//                                                         options: nil) { [weak self] in
//            self?.updateState()
//        }
    }
    
    internal func updateState() {
        self.extensionController.getState { state in
            DispatchQueue.main.async {
                self.enabled = (state == .enabled)
            }
        }
    }
    
    internal func openSafariPreferences() {
        self.extensionController.openSafariPreferences()
    }
    
    internal func updateSettings() {
        do {
            try self.defaults?.set(self.settings.encode(), forKey: self.lastKnownExtensionSettingsKey)
        } catch {
            os_log(.error, log: self.log, "error saving settings: %{public}s", error.localizedDescription)
        }
        
        os_log(.info, log: self.log, "Will send settings to Safari App Extension")
        guard let encodedSettings = try? self.settings.encode() else {
            os_log(.error, log: self.log, "Failed to encode settings to json")
            return
        }
        self.extensionController.sendSettingsToExtension(name: ExtensionSettings.settingsMessageName,
                                                         settings: [ExtensionSettings.settingsMessageKey: encodedSettings])
    }
}
