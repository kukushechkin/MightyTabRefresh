//
//  ExtensionController+testable.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 21.8.2021.
//

import Foundation
import ExtensionSettings

struct ExtensionControllerMock: ExtensionControllerProtocol {
    let enabled: Bool

    func getState(_ callback: @escaping (ExtensionState) -> Void) {
        callback(self.enabled ? .enabled : .disabled)
    }

    func openSafariPreferences() {
        //
    }

    func sendSettingsToExtension(name: String, settings: [String: Any]) {
        //
    }
}
