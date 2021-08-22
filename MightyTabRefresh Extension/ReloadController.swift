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
    
    private var activePages: [SFSafariPage] = []
    private var timers: [Timer] = []
    
    // MARK: - ReloadControllerProtocol
    
    var settings: ExtensionSettings? {
        get {
            // no getter
            nil
        }
        set {
            self.queue.async {
                self.timers.forEach { timer in
                    timer.invalidate()
                }
                self.timers.removeAll()
                newValue?.rules.forEach({ rule in
                    if rule.enabled && !rule.pattern.isEmpty {
                        os_log(.debug, log: self.log, "will setup timer for %{public}s", rule.pattern)
                        self.setupTimerFor(rule: rule)
                    }
                })
            }
        }
    }
    
    func add(page: SFSafariPage) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
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
    
    // MARK: - private
    
    private func setupTimerFor(rule: Rule) {
        DispatchQueue.main.async {
            // will more taking a slice of pages into the closure be more efficient?
            let newTimer = Timer.scheduledTimer(withTimeInterval: rule.refreshInterval, repeats: true) {_ in
                os_log(.debug, log: self.log, "firing timer for %{public}s", rule.pattern)
                self.activePages.forEach { page in
                    page.getPropertiesWithCompletionHandler { props in
                        guard let props = props else { return }
                        if props.url?.host?.contains(rule.pattern) ?? false {
                            page.reload()
                        }
                    }
                }
            }
            os_log(.debug, log: self.log, "appending timer for %{public}s", rule.pattern)
            self.timers.append(newTimer)
        }
    }
    
    private func sendMessageToPages(patterns: [String], key: String, data: [String : Any]) {
        self.activePages.forEach { page in
            page.getPropertiesWithCompletionHandler { properties in
                guard let properties = properties else {
                    os_log(.debug, log: self.log, "inactive page detected")
                    return
                }
                if !patterns.filter({ pattern in
                    properties.url?.host?.contains(pattern) ?? false
                }).isEmpty {
                    page.dispatchMessageToScript(withName: key, userInfo: data)
                }
            }
        }
    }
}
