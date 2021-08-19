//
//  ReloadController.swift
//  MightyTabRefresh Extension
//
//  Created by Kukushkin, Vladimir on 19.8.2021.
//

import Foundation
import SafariServices
import os.log

import ExtensionSettings

protocol ReloadControllerProtocol {
    var settings: ExtensionSettings? {
        get set
    }
    
    func add(page: SFSafariPage)
    func remove(page: SFSafariPage)
}

class ReloadController: ReloadControllerProtocol {
    private let log = OSLog(subsystem: "com.kukushechkin.MightyTabRefresh", category: "ReloadController")
    private let queue = DispatchQueue(label: "com.kukushechkin.MightyTabRefresh.extension.queue")
    
    var settings: ExtensionSettings?
    private var activePages: [SFSafariPage] = []
    private var timers: [Timer] = []
    
    init() {
        let defaultTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) {_ in
            os_log(.debug, log: self.log, "firing timer")
            self.activePages.forEach { page in
                page.reload()
            }
        }
        self.timers.append(defaultTimer)
    }
    
    func add(page: SFSafariPage) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            // TODO: clean inactive pages
            self.activePages.append(page)
            os_log(.debug, log: self.log, "pages registered: %d", self.activePages.count)
        }
    }
    
    func remove(page: SFSafariPage) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            self.activePages.removeAll { yetAnotherPage in
                yetAnotherPage == page
            }
        }
    }
    
    func sendMessageToPages(patterns: [String], key: String, data: [String : Any]) {
        self.activePages.forEach { page in
            page.getPropertiesWithCompletionHandler { properties in
                guard let properties = properties else {
                    os_log(.debug, log: self.log, "inactive page detected")
                    return
                }
                if !patterns.filter({ pattern in
                    // TODO: actually apply pattern
                    // TODO: define what is pattern
                    properties.url?.host?.contains(pattern) ?? false
                }).isEmpty {
                    page.dispatchMessageToScript(withName: key, userInfo: data)
                }
            }
        }
    }
}
