//
//  ExtensionController+testable.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 21.8.2021.
//

import ExtensionSettings
import Foundation

struct ExtensionControllerMock: ExtensionControllerProtocol {
    let enabled: Bool

    func getState(_ callback: @escaping (ExtensionState) -> Void) {
        callback(enabled ? .enabled : .disabled)
    }

    func openSafariPreferences() {
        //
    }

    func sendSettingsToExtension(name _: String, settings _: [String: Any]) {
        //
    }
}
