//
//  SafariExtensionViewController.swift
//  MightyTabRefresh Extension
//
//  Created by Kukushkin, Vladimir on 10.7.2021.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width: 320, height: 240)
        return shared
    }()
}
