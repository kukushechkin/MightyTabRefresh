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
    
    override init() {
        super.init()
        os_log(.debug, log: self.log, "[%{public}s]: init", self.id.uuidString)
        
        if Self.reloadController != nil {
            os_log(.debug, log: self.log, "[%{public}s]: reloadController already exists", self.id.uuidString)
            return
        }
        Self.reloadController = ReloadController()
        
        self.defaults?
            .publisher(for: \.lastKnownExtensionSettings)
            .sink { newSettings in
                os_log(.debug, log: self.log, "[%{public}s]: observed new settings", self.id.uuidString)
                if let settings = newSettings as? ExtensionSettings {
                    os_log(.debug, log: self.log, "[%{public}s]: decoded new settings: %s", self.id.uuidString, settings.rules.debugDescription)
                    Self.reloadController?.settings = settings
                }
            }
            .store(in: &subscriptions)
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
        // Settings arrive only through shared UserDefaults to avoid switching focus to Safari
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
