//
//  SafariExtensionHandler.swift
//  MightyTabRefresh Extension
//
//  Created by Kukushkin, Vladimir on 10.7.2021.
//

import Combine
import os.log
import SafariServices

import ExtensionSettings

let lastKnownExtensionSettingsKey = "lastKnownExtensionSettings"

let pageLoadedMessageKey = "com.kukushechkin.MightyTabRefresh.scriptPageLoaded"
let pageWillUnloadMessageKey = "com.kukushechkin.MightyTabRefresh.scriptPageWillUnload"
let pageBecameActiveMessageKey = "com.kukushechkin.MightyTabRefresh.scriptPageBecameActive"
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
            set(newValue, forKey: lastKnownExtensionSettingsKey)
        }
    }
}

class SafariExtensionHandler: SFSafariExtensionHandler {
    private static var reloadController: ReloadController<SafariPageWrapper>?

    private let id = UUID()
    private let log = OSLog(subsystem: "com.kukushechkin.MightyTabRefresh", category: "SafariExtensionHandler")
    private let defaults = UserDefaults(suiteName: "AC5986BBE6.com.kukushechkin.MightyTabRefresh.appGroup")
    private var subscriptions = Set<AnyCancellable>()

    private func selfUuid() -> String {
        // Use for SFSafariExtensionHandler instances debugging
        id.uuidString
    }

    override init() {
        super.init()
        os_log(.debug, log: log, "[%{public}s]: init", selfUuid())

        if Self.reloadController != nil {
            os_log(.debug, log: log, "[%{public}s]: reloadController already exists", selfUuid())
            return
        }
        Self.reloadController = ReloadController()

        defaults?
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
        os_log(.debug, log: log,
               "[%{public}s]: Got event from the inject script at %{public}s: %{public}s",
               selfUuid(),
               userInfo!["url"] as? String ?? "unknown",
               messageName)

        weak var weakself = self
        page.getPropertiesWithCompletionHandler { properties in
            guard let self = weakself else { return }
            guard properties?.url?.host != nil else {
                os_log(.debug, log: self.log, "[%{public}s]: blank page, ignore", self.selfUuid())
                return
            }

            if messageName == pageWillUnloadMessageKey {
                Self.reloadController?.removePage(page: SafariPageWrapper(page: page))
            }
            if messageName == pageBecameActiveMessageKey {
                Self.reloadController?.pageBecameActive(page: SafariPageWrapper(page: page))
            }
            if messageName == pageBecameInactiveMessageKey {
                Self.reloadController?.pageBecameInactive(page: SafariPageWrapper(page: page))
            }
        }
    }

    override func messageReceivedFromContainingApp(withName _: String, userInfo _: [String: Any]? = nil) {
        // Settings arrive only through shared UserDefaults to avoid switching focus to Safari
    }

    override func toolbarItemClicked(in _: SFSafariWindow) {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        let parentBundleUrl = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        NSWorkspace.shared.openApplication(at: parentBundleUrl, configuration: configuration) { _, error in
            if let error = error {
                os_log(.error, log: self.log, "[%{public}s]: failed to open app: %{public}s", self.selfUuid(), error.localizedDescription)
            }
        }
    }

    override func validateToolbarItem(in _: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
}
