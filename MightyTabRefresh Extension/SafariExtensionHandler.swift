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
    private let log = OSLog(subsystem: "com.kukushechkin.MightyRefresh", category: "SafariExtensionHandler")
    private var settings: ExtensionSettings?
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
        }
    }

    override func messageReceivedFromContainingApp(withName messageName: String, userInfo: [String : Any]? = nil) {
        os_log(.debug, log: self.log, "The extension received a message %s", messageName)
        guard let userInfo = userInfo else {
            os_log(.debug, log: self.log, "Empty userInfo, ignore")
            return
        }
        if messageName != ExtensionSettings.settingsMessageName {
            os_log(.debug, log: self.log, "Message is not %{public}s, ignore", ExtensionSettings.settingsMessageName)
            return
        }
        if !userInfo.keys.contains(ExtensionSettings.settingsMessageKey) {
            os_log(.debug, log: self.log, "Message does not contain %{public}s key, ignore", ExtensionSettings.settingsMessageKey)
            return
        }
        guard let settingsJson = userInfo[ExtensionSettings.settingsMessageKey] else {
            os_log(.info, log: self.log, "empty %{public}s, ignore", ExtensionSettings.settingsMessageKey)
            return
        }
        
        os_log(.debug, log: self.log, "Will try to decode settings: %{public}s", userInfo[ExtensionSettings.settingsMessageKey].debugDescription)
        guard let newSettings = ExtensionSettings(from: settingsJson) else {
            os_log(.debug, log: self.log, "Failed to decode ExtensionSettings from %{public}s, ignore", ExtensionSettings.settingsMessageKey)
            return
        }
        
        // TODO: settings description
        os_log(.debug, log: self.log, "Got new settings")
        self.settings = newSettings
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
