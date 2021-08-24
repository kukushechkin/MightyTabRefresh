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

let lastKnownExtensionStateKey = "lastKnownExtensionState"
let lastKnownExtensionSettingsKey = "lastKnownExtensionSettings"

internal class ExtensionViewModel: ObservableObject {
    private let log = OSLog(subsystem: "com.kukushechkin.MightyTabRefresh", category: "ExtensionViewModel")
    private let statusRefreshQueue = DispatchQueue(label: "com.kukushechkin.MightyTabRefresh.extensionCheckQueue")
    private let defaults = UserDefaults(suiteName: "AC5986BBE6.com.kukushechkin.MightyTabRefresh.appGroup")
    private var timer: Timer?
    private var timerCancelTimer: Timer?
    
    private let extensionStateUpdateInterval = 1.0
    private let extensionStateUpdateCancelInterval = 15.0
    
    private let extensionController: ExtensionControllerProtocol
    
    @Published var enabled: Bool
    @Published var settings: ExtensionSettings
        
    internal init(extensionController: ExtensionControllerProtocol) {
        self.extensionController = extensionController
        self.enabled = defaults?.bool(forKey: lastKnownExtensionStateKey) ?? false
            
        if let persistentData = defaults?.object(forKey: lastKnownExtensionSettingsKey),
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
        
        // Will ask Safari for a state update
        self.updateState()
        
        self.observeItems(propertyToObserve: self.$settings)
    }
    
    // TODO: move to a category/whatever
    // https://stackoverflow.com/questions/63479425/observing-a-published-var-from-another-object
    var itemObserver: AnyCancellable?
    func observeItems<P: Publisher>(propertyToObserve: P) where P.Output == ExtensionSettings, P.Failure == Never {
       itemObserver = propertyToObserve
            .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
            .sink {_ in
                os_log(.debug, log: self.log, "observed settings update")
                self.updateSettings()
            }
    }
    
    internal func updateState() {
        self.extensionController.getState { state in
            DispatchQueue.main.async {
                self.enabled = (state == .enabled)
            }
        }
    }
    
    internal func openSafariPreferences() {
        DispatchQueue.main.async {
            os_log(.info, log: self.log, "will start monitoring extension state")
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: self.extensionStateUpdateInterval, repeats: true) { _ in
                self.updateState()
            }
            
            // \(self.extensionStateUpdateCancelInterval) secs of CPU load for the better UX
            self.timerCancelTimer = Timer.scheduledTimer(withTimeInterval: self.extensionStateUpdateCancelInterval, repeats: false) { _ in
                self.timer?.invalidate()
                self.timer = nil
                self.timerCancelTimer?.invalidate()
                self.timerCancelTimer = nil
            }
        }
        self.extensionController.openSafariPreferences()
    }
    
    internal func updateSettings() {
        do {
            try self.defaults?.set(self.settings.encode(), forKey: lastKnownExtensionSettingsKey)
        } catch {
            os_log(.error, log: self.log, "error saving settings: %{public}s", error.localizedDescription)
        }
        os_log(.info, log: self.log, "Saved new settings in shared defaults")
        
        // This will remove focus from the app and activate Safari which is not a good experience during editing
        // Relying only on UserDefaults to transfer settings
        
//        os_log(.info, log: self.log, "Will send settings to Safari App Extension")
//        guard let encodedSettings = try? self.settings.encode() else {
//            os_log(.error, log: self.log, "Failed to encode settings to json")
//            return
//        }
//        self.extensionController.sendSettingsToExtension(name: ExtensionSettings.settingsMessageName,
//                                                         settings: [ExtensionSettings.settingsMessageKey: encodedSettings])
    }
}
