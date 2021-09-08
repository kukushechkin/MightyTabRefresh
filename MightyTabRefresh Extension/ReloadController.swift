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
class PageReloadingObject {
    /// page object
    let page: SFSafariPage

    /// the most frequent rule for this page
    var rule: Rule?

    /// active timer, if nil there is user activity on the page
    var timer: Timer?

    init(page: SFSafariPage, rule: Rule?, timer: Timer?) {
        self.page = page
        self.rule = rule
        self.timer = timer
    }
}

class ReloadController {
    private let log = OSLog(subsystem: "com.kukushechkin.MightyTabRefresh", category: "ReloadController")
    private let queue = DispatchQueue(label: "com.kukushechkin.MightyTabRefresh.extension.queue")

    private var trackedPages: [SFSafariPage: PageReloadingObject] = [:]
    private var settings: ExtensionSettings?

    func updateSettings(settings: ExtensionSettings) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            self.settings = settings
            self.trackedPages.forEach { (safariPage, pageObject) in
                if pageObject.timer != nil {
                    pageObject.timer?.invalidate()
                    pageObject.timer = nil
                    pageObject.rule = self.ruleFor(page: safariPage)
                    if let rule = pageObject.rule {
                        self.setupTimerFor(rule: rule, page: safariPage)
                    }
                }
            }
        }
    }

    func removePage(page: SFSafariPage) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            if self.trackedPages[page] == nil {
                os_log(.error, log: self.log, "zombie page (%s) detected", page.host)
                return
            }

            os_log(.debug, log: self.log, "will remove page (%s)", self.trackedPages[page]?.page.host ?? "")
            if let timer = self.trackedPages[page]?.timer {
                timer.invalidate()
            }
            self.trackedPages[page] = nil
            os_log(.debug, log: self.log, "pages registered: %d", self.trackedPages.count)
        }
    }

    func pageBecameActive(page: SFSafariPage) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            self.addPageIfNeeded(page: page)

            os_log(.debug, log: self.log, "page (%s) became active", page.host)
            self.trackedPages[page]?.timer?.invalidate()
            self.trackedPages[page]?.timer = nil
        }
    }

    func pageBecameInactive(page: SFSafariPage) {
        self.queue.async { [weak self] in
            guard let self = self else { return }
            self.addPageIfNeeded(page: page)

            os_log(.debug, log: self.log, "page (%s) became inactive", page.host)

            guard self.trackedPages[page]?.timer == nil else {
                os_log(.debug, log: self.log, "timer for page (%s) is already active", page.host)
                return
            }

            guard let rule = self.trackedPages[page]?.rule else {
                os_log(.debug, log: self.log, "no rule for page (%s), will not set timer", page.host)
                return
            }

            self.setupTimerFor(rule: rule, page: page)
        }
    }

    // MARK: - private

    private func addPageIfNeeded(page: SFSafariPage) {
        if self.trackedPages[page] != nil {
            os_log(.info, log: self.log, "page (%s) already tracked, will not add", page.host)
            return
        }

        os_log(.info, log: self.log, "new page (%s) detected, will add", page.host)
        let rule = self.ruleFor(page: page)
        self.trackedPages[page] = PageReloadingObject(page: page, rule: rule, timer: nil)
        os_log(.debug, log: self.log, "pages registered: %d", self.trackedPages.count)
    }

    private func setupTimerFor(rule: Rule, page: SFSafariPage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            os_log(.debug, log: self.log, "will set timer for (%s) with interval %f", page.host, rule.refreshInterval)
            self.trackedPages[page]?.timer = Timer.scheduledTimer(withTimeInterval: rule.refreshInterval, repeats: true) { _ in
                os_log(.debug, log: self.log, "firing timer for page (%s) with rule %{public}s", rule.pattern, page.host)
                page.reload()
            }
        }
    }

    private func ruleFor(page: SFSafariPage) -> Rule? {
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
            if rule.matches(host: page.host) {
                return rule
            }
            return partialResult
        })

        if let rule = rule {
            os_log(.debug, log: self.log, "rule with pattern %{public}s matches page host %s", rule.pattern, page.host)
        } else {
            os_log(.debug, log: self.log, "no rule matches page host %s", page.host)
        }

        return rule
    }
}
