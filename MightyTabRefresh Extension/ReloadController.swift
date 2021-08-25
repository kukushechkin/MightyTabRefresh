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

/// Holds information of what page when should be reloaded
struct PageReloadingObject {
    /// page object
    let page: SFSafariPage

    /// the most frequent rule for this page
    var rule: Rule?

    /// active timer, if nil there is user activity on the page
    var timer: Timer?
}

class ReloadController {
    private let log = OSLog(subsystem: "com.kukushechkin.MightyTabRefresh", category: "ReloadController")
    private let queue = DispatchQueue(label: "com.kukushechkin.MightyTabRefresh.extension.queue")

    private var trackedPages: [String: PageReloadingObject] = [:]
    private var settings: ExtensionSettings?

    func updateSettings(settings: ExtensionSettings) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            self.settings = settings
            self.trackedPages.keys.forEach { uuid in
                guard var trackedPage = self.trackedPages[uuid],
                      let _ = trackedPage.timer else { return }
                
                trackedPage.timer?.invalidate()
                trackedPage.timer = nil
                trackedPage.rule = self.ruleFor(page: trackedPage.page)
                if let rule = trackedPage.rule {
                    self.setupTimerFor(uuid: uuid, rule: rule, page: trackedPage.page)
                }
            }
        }
    }

    func addPage(uuid: String, page: SFSafariPage) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            os_log(.debug, log: self.log, "will add new page %{public}s (%s)", uuid, page.host)
            let rule = self.ruleFor(page: page)
            self.trackedPages[uuid] = PageReloadingObject(page: page, rule: rule, timer: nil)
            os_log(.debug, log: self.log, "pages registered: %d", self.trackedPages.count)
        }
    }
    
    func removePage(uuid: String) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            os_log(.debug, log: self.log, "will remove page %{public}s (%s)", uuid, self.trackedPages[uuid]?.page.host ?? "")
            self.trackedPages[uuid]?.timer?.invalidate()
            self.trackedPages[uuid] = nil
        }
    }
    
    func pageBecameActive(uuid: String) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            os_log(.debug, log: self.log, "page %{public}s (%s) became active", uuid, self.trackedPages[uuid]?.page.host ?? "")
            self.trackedPages[uuid]?.timer?.invalidate()
            self.trackedPages[uuid]?.timer = nil
        }
    }
    
    func pageBecameInactive(uuid: String) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            os_log(.debug, log: self.log, "page %{public}s (%s) became inactive", uuid, self.trackedPages[uuid]?.page.host ?? "")
            if self.trackedPages[uuid]?.timer == nil,
               let rule = self.trackedPages[uuid]?.rule,
               let page = self.trackedPages[uuid]?.page {
                self.setupTimerFor(uuid: uuid, rule: rule, page: page)
            }
        }
    }
    
    // MARK: - private
    
    private func setupTimerFor(uuid: String, rule: Rule, page: SFSafariPage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            os_log(.debug, log: self.log, "will set timer for %{public}s (%s) with interval %d", uuid, page.host, rule.refreshInterval)
            self.trackedPages[uuid]?.timer = Timer.scheduledTimer(withTimeInterval: rule.refreshInterval, repeats: true) { _ in
                os_log(.debug, log: self.log, "firing timer for page %{public}s (%s) with rule %{public}s", uuid, rule.pattern, page.host)
                page.reload()
            }
        }
    }
  
    private func ruleFor(page: SFSafariPage) -> Rule? {
        let pageHost = page.host
        let rule = self.settings?.rules.reduce(nil as Rule?, { partialResult, rule in
            if !rule.enabled || rule.pattern.isEmpty {
                return partialResult
            }
            
            // comparing TimeIntervals is cheap, matching patterns is expensive
            if let partialResult = partialResult {
                if partialResult.refreshInterval < rule.refreshInterval {
                    return partialResult
                }
            }
            if rule.matches(host: pageHost) {
                return rule
            }
            return nil
        })

        if let rule = rule {
            os_log(.debug, log: self.log, "rule with pattern %{public}s matches page host %s", rule.pattern, pageHost)
        } else {
            os_log(.debug, log: self.log, "no rule match page host %s", pageHost)
        }
        
        return rule
    }
}
