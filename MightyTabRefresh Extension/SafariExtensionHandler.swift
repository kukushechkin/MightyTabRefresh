//
//  SafariExtensionHandler.swift
//  MightyTabRefresh Extension
//
//  Created by Kukushkin, Vladimir on 10.7.2021.
//

import SafariServices
import os.log
import Combine

import ExtensionSettings

let lastKnownExtensionSettingsKey = "lastKnownExtensionSettings"

let pageLoadedMessageKey         = "com.kukushechkin.MightyTabRefresh.scriptPageLoaded"
let pageWillUnloadMessageKey     = "com.kukushechkin.MightyTabRefresh.scriptPageWillUnload"
let pageBecameActiveMessageKey   = "com.kukushechkin.MightyTabRefresh.scriptPageBecameActive"
let pageBecameInactiveMessageKey = "com.kukushechkin.MightyTabRefresh.scriptPageBecameInactive"

extension UserDefaults {
    @objc var lastKnownExtensionSettings: Any? {
        get {
            if let object = object(forKey: lastKnownExtensionSettingsKey) {
                return ExtensionSettings(from: object)
            }
            return nil
        }
        set {
            self.set(newValue, forKey: lastKnownExtensionSettingsKey)
        }
    }
}

class SafariExtensionHandler: SFSafariExtensionHandler {
    static private var reloadController: ReloadController?
    
    private let id = UUID()
    private let log = OSLog(subsystem: "com.kukushechkin.MightyTabRefresh", category: "SafariExtensionHandler")
    private let defaults = UserDefaults(suiteName: "AC5986BBE6.com.kukushechkin.MightyTabRefresh.appGroup")
    private var subscriptions = Set<AnyCancellable>()
    
    private func selfUuid() -> String {
        // Use for SFSafariExtensionHandler instances debugging
        // self.id.uuidString
        ""
    }
    
    override init() {
        super.init()
        os_log(.debug, log: self.log, "[%{public}s]: init", self.selfUuid())
        
        if Self.reloadController != nil {
            os_log(.debug, log: self.log, "[%{public}s]: reloadController already exists", self.selfUuid())
            return
        }
        Self.reloadController = ReloadController()
        
        self.defaults?
            .publisher(for: \.lastKnownExtensionSettings)
            .sink { newSettings in
                os_log(.debug, log: self.log, "[%{public}s]: observed new settings", self.selfUuid())
                if let settings = newSettings as? ExtensionSettings {
                    os_log(.debug, log: self.log, "[%{public}s]: decoded new settings: %s", self.selfUuid(), settings.rules.debugDescription)
                    Self.reloadController?.updateSettings(settings: settings)
                }
            }
            .store(in: &subscriptions)
    }
    
    deinit {
        os_log(.debug, log: self.log, "[%{public}s]: dealloc", self.selfUuid())
    }
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
        os_log(.debug, log: self.log, "[%{public}s]: Got event from the inject script: %{public}s", self.selfUuid(), messageName)

        weak var weakself = self
        page.getPropertiesWithCompletionHandler { properties in
            guard let self = weakself else { return }
            guard let pageUuid = userInfo?["uuid"] as? String else {
                os_log(.debug, log: self.log, "[%{public}s]: page did not provide uuid, ignore", self.selfUuid())
                return
            }
            guard let host = properties?.url?.host else {
                os_log(.debug, log: self.log, "[%{public}s]: blank page, ignore", self.selfUuid())
                return
            }
            
            if messageName == pageLoadedMessageKey {
                os_log(.debug, log: self.log, "[%{public}s]: page %{public}s (%s) loaded", self.selfUuid(), pageUuid, host)
                Self.reloadController?.addPage(uuid: pageUuid, page: page)
            }
            if messageName == pageWillUnloadMessageKey {
                os_log(.debug, log: self.log, "[%{public}s]: page %{public}s (%s) will unload", self.selfUuid(), pageUuid, host)
                Self.reloadController?.removePage(uuid: pageUuid)
            }
            if messageName == pageBecameActiveMessageKey {
                os_log(.debug, log: self.log, "[%{public}s]: page %{public}s (%s) became active", self.selfUuid(), pageUuid, host)
                Self.reloadController?.pageBecameActive(uuid: pageUuid)
            }
            if messageName == pageBecameInactiveMessageKey {
                os_log(.debug, log: self.log, "[%{public}s]: page %{public}s (%s) became inactive", self.selfUuid(), pageUuid, host)
                Self.reloadController?.pageBecameInactive(uuid: pageUuid)
            }
        }
    }

    override func messageReceivedFromContainingApp(withName messageName: String, userInfo: [String: Any]? = nil) {
        // Settings arrive only through shared UserDefaults to avoid switching focus to Safari
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        let parentBundleUrl = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        NSWorkspace.shared.openApplication(at: parentBundleUrl, configuration: configuration) { _, error in
            if let error = error {
                os_log(.error, log: self.log, "[%{public}s]: failed to open app: %{public}s", self.selfUuid(), error.localizedDescription)
            }
        }
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
}
