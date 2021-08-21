//
//  SafariExtensionHandler.swift
//  MightyTabRefresh Extension
//
//  Created by Kukushkin, Vladimir on 10.7.2021.
//

import SafariServices
import os.log

import ExtensionSettings

class SafariExtensionHandler: SFSafariExtensionHandler {
    static private var reloadController: ReloadController?
    
    private let id = UUID()
    private let log = OSLog(subsystem: "com.kukushechkin.MightyTabRefresh", category: "SafariExtensionHandler")
    private let defaults = UserDefaults(suiteName: "AC5986BBE6.com.kukushechkin.MightyTabRefresh.appGroup")
        
    private let lastKnownExtensionSettingsKey = "lastKnownExtensionSettings"
    
    override init() {
        super.init()
        os_log(.debug, log: self.log, "[%{public}s]: init", self.id.uuidString)
        
        if Self.reloadController != nil {
            os_log(.debug, log: self.log, "[%{public}s]: reloadController already exists", self.id.uuidString)
            return
        }
        Self.reloadController = ReloadController()
        
        guard let defaults = self.defaults else {
            os_log(.debug, log: self.log, "[%{public}s]: No defaults, bail out", self.id.uuidString)
            return
        }
        guard let persistentData = defaults.object(forKey: self.lastKnownExtensionSettingsKey) else {
            os_log(.debug, log: self.log, "[%{public}s]: No data in defaults, bail out", self.id.uuidString)
            return
        }
        guard let settings = ExtensionSettings(from: persistentData) else {
            os_log(.debug, log: self.log, "[%{public}s]: No settings, bail out", self.id.uuidString)
            return
        }
        
        os_log(.debug, log: self.log, "[%{public}s]: will set initial reloadController settings", self.id.uuidString)
        Self.reloadController?.settings = settings
    }
    
    deinit {
        os_log(.debug, log: self.log, "[%{public}s]: dealloc", self.id.uuidString)
    }
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        os_log(.debug, log: self.log, "[%{public}s]: Got event from the inject script: %{public}s", self.id.uuidString, messageName)

        weak var weakself = self
        page.getPropertiesWithCompletionHandler { properties in
            guard let self = weakself else { return }
            os_log(.debug, log: self.log, "[%{public}s]: Injected script page with url %{public}s is now active", self.id.uuidString, properties?.url?.host ?? "<none>")
            if messageName == ExtensionSettings.scriptBecameActiveMessageKey {
                os_log(.debug, log: self.log, "[%{public}s]: will add page for %{public}s", self.id.uuidString, properties?.url?.host ?? "<none>")
                Self.reloadController?.add(page: page)
            }
        }
    }

    override func messageReceivedFromContainingApp(withName messageName: String, userInfo: [String : Any]? = nil) {
        os_log(.debug, log: self.log, "[%{public}s]: The extension received a message %s", self.id.uuidString, messageName)
        guard let userInfo = userInfo else {
            os_log(.debug, log: self.log, "[%{public}s]: Empty userInfo, ignore", self.id.uuidString)
            return
        }
        if messageName != ExtensionSettings.settingsMessageName {
            os_log(.debug, log: self.log, "[%{public}s]: Message is not %{public}s, ignore", self.id.uuidString, ExtensionSettings.settingsMessageName)
            return
        }
        if !userInfo.keys.contains(ExtensionSettings.settingsMessageKey) {
            os_log(.debug, log: self.log, "[%{public}s]: Message does not contain %{public}s key, ignore", self.id.uuidString, ExtensionSettings.settingsMessageKey)
            return
        }
        guard let settingsJson = userInfo[ExtensionSettings.settingsMessageKey] else {
            os_log(.info, log: self.log, "[%{public}s]: empty %{public}s, ignore", self.id.uuidString, ExtensionSettings.settingsMessageKey)
            return
        }

        os_log(.debug, log: self.log, "[%{public}s]: Will try to decode settings: %{public}s", self.id.uuidString, userInfo[ExtensionSettings.settingsMessageKey].debugDescription)
        guard let newSettings = ExtensionSettings(from: settingsJson) else {
            os_log(.debug, log: self.log, "[%{public}s]: Failed to decode ExtensionSettings from %{public}s, ignore", self.id.uuidString, ExtensionSettings.settingsMessageKey)
            return
        }

        os_log(.debug, log: self.log, "[%{public}s]: Got new settings", self.id.uuidString)
        Self.reloadController?.settings = newSettings
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
//        self.activePages.forEach { host, _ in
//            os_log(.debug, log: self.log, "another active page: %{public}s", host)
//        }
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
}
