//
//  ReloadController.swift
//  MightyTabRefresh Extension
//
//  Created by Kukushkin, Vladimir on 19.8.2021.
//

import Foundation
import os.log
import SafariServices

import ExtensionSettings

enum PageReloadingObjectState {
    case active
    case inactive
}

/// Holds information of what page when should be reloaded
class PageReloadingObject<T: SafariPageWrapperProtocol> {
    /// page wrapper
    let page: T

    /// the most frequent rule for this page
    var rule: Rule?

    /// active timer, if nil there is user activity on the page
    var timer: Timer?

    /// is user currently at this page
    var state: PageReloadingObjectState

    init(page: T, rule: Rule?, timer: Timer?, state: PageReloadingObjectState) {
        self.page = page
        self.rule = rule
        self.timer = timer
        self.state = state
    }
}

class ReloadController<T: SafariPageWrapperProtocol & Hashable> {
    private let log = OSLog(subsystem: "com.kukushechkin.MightyTabRefresh", category: "ReloadController")
    private let queue = DispatchQueue(label: "com.kukushechkin.MightyTabRefresh.extension.queue")

    private var trackedPages: [T: PageReloadingObject<T>] = [:]
    private var settings: ExtensionSettings?

    func updateSettings(settings: ExtensionSettings) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.settings = settings
            self.trackedPages.forEach { safariPage, pageObject in
                if pageObject.timer != nil {
                    // invalidate timers for all pages with timers
                    pageObject.timer?.invalidate()
                    pageObject.timer = nil
                    // start new timers only for pages having timers before
                }
                pageObject.rule = self.ruleFor(page: safariPage)
                if let rule = pageObject.rule,
                   pageObject.state == .inactive
                {
                    self.setupTimerFor(rule: rule, page: safariPage)
                }
            }
        }
    }

    func removePage(page: T) {
        queue.async { [weak self] in
            guard let self = self else { return }
            if self.trackedPages[page] == nil {
                os_log(.error, log: self.log, "zombie page (%{public}s) detected", page.host)
                return
            }

            os_log(.debug, log: self.log, "will remove page (%{public}s)", self.trackedPages[page]?.page.host ?? "")
            if let timer = self.trackedPages[page]?.timer {
                timer.invalidate()
            }
            self.trackedPages[page] = nil
            os_log(.debug, log: self.log, "pages registered: %d", self.trackedPages.count)
        }
    }

    func pageBecameActive(page: T) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.addPageIfNeeded(page: page, state: .active)

            os_log(.debug, log: self.log, "page (%{public}s) became active", page.host)
            self.trackedPages[page]?.timer?.invalidate()
            self.trackedPages[page]?.timer = nil
        }
    }

    func pageBecameInactive(page: T) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.addPageIfNeeded(page: page, state: .inactive)

            os_log(.debug, log: self.log, "page (%{public}s) became inactive", page.host)

            guard self.trackedPages[page]?.timer == nil else {
                os_log(.debug, log: self.log, "timer for page (%{public}s) is already active", page.host)
                return
            }

            guard let rule = self.trackedPages[page]?.rule else {
                os_log(.debug, log: self.log, "no rule for page (%{public}s), will not set timer", page.host)
                return
            }

            self.setupTimerFor(rule: rule, page: page)
        }
    }

    // MARK: - private and internal

    // this can actually be turned into the way to get pages inside ReloadController, not just tests
    func getTrackedPages() -> [T: PageReloadingObject<T>] {
        let group = DispatchGroup()
        var pages: [T: PageReloadingObject<T>] = [:]
        group.enter()
        queue.async {
            pages = self.trackedPages
            group.leave()
        }
        group.wait()
        return pages
    }

    private func addPageIfNeeded(page: T, state: PageReloadingObjectState) {
        if trackedPages[page] != nil {
            os_log(.info, log: log, "page (%{public}s) already tracked, will not add", page.host)
            return
        }

        os_log(.info, log: log, "new page (%s) detected, will add", page.host)
        let rule = ruleFor(page: page)
        trackedPages[page] = PageReloadingObject(page: page, rule: rule, timer: nil, state: state)
        os_log(.debug, log: log, "pages registered: %d", trackedPages.count)
    }

    private func setupTimerFor(rule: Rule, page: T) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            os_log(.debug, log: self.log, "will set timer for (%s) with interval %f", page.host, rule.refreshInterval)
            self.trackedPages[page]?.timer = Timer.scheduledTimer(withTimeInterval: rule.refreshInterval, repeats: true) { _ in
                os_log(.debug, log: self.log, "firing timer for page (%{public}s) with rule %{public}s", page.host, rule.pattern)
                page.reload()
            }
        }
    }

    private func ruleFor(page: T) -> Rule? {
        let rule = settings?.rules.reduce(nil as Rule?) { partialResult, rule in
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
        }

        if let rule = rule {
            os_log(.debug, log: log, "rule with pattern %{public}s matches page host %s", rule.pattern, page.host)
        } else {
            os_log(.debug, log: log, "no rule matches page host %s", page.host)
        }

        return rule
    }
}
