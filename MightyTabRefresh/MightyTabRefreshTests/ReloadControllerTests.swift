//
//  ReloadControllerTests.swift
//  ReloadControllerTests
//
//  Created by Kukushkin, Vladimir on 8.9.2021.
//

import ExtensionSettings
import SafariServices
import XCTest

struct SafariPageWrapperMock: SafariPageWrapperProtocol {
    var reloadExpectation: XCTestExpectation?
    var host: String

    func reload() {
        reloadExpectation?.fulfill()
    }
}

class ReloadControllerTests: XCTestCase {
    let reloadController = ReloadController<SafariPageWrapperMock>()

    let settings = ExtensionSettings(rules: [
        Rule(enabled: true, pattern: "host1", refreshInterval: 1.0),
        Rule(enabled: true, pattern: "host2", refreshInterval: 1.0),
        Rule(enabled: false, pattern: "host3", refreshInterval: 1.0),
        Rule(enabled: true, pattern: "host4", refreshInterval: 5.0),
    ])

    var page1 = SafariPageWrapperMock(reloadExpectation: nil, host: "www.host1.com")
    var page2 = SafariPageWrapperMock(reloadExpectation: nil, host: "host2.com")
    var page3 = SafariPageWrapperMock(reloadExpectation: nil, host: "www.host3.com")
    var page4 = SafariPageWrapperMock(reloadExpectation: nil, host: "www.host4.com")

    func testPagesComeAndGo() throws {
        XCTAssertEqual(reloadController.getTrackedPages().count, 0)
        reloadController.pageBecameActive(page: page1)
        XCTAssertEqual(reloadController.getTrackedPages().count, 1)
        reloadController.pageBecameInactive(page: page2)
        XCTAssertEqual(reloadController.getTrackedPages().count, 2)
        reloadController.pageBecameInactive(page: page1)
        XCTAssertEqual(reloadController.getTrackedPages().count, 2)
        reloadController.removePage(page: page1)
        XCTAssertEqual(reloadController.getTrackedPages().count, 1)
        reloadController.removePage(page: page1)
        XCTAssertEqual(reloadController.getTrackedPages().count, 1)
        reloadController.removePage(page: page2)
        XCTAssertEqual(reloadController.getTrackedPages().count, 0)
    }

    func testPageRefreshIntervalUpdate() throws {
        page1.reloadExpectation = expectation(description: "page 1 was updated 2 times after settings update")
        page1.reloadExpectation!.expectedFulfillmentCount = 2
        page1.reloadExpectation!.assertForOverFulfill = false
        reloadController.pageBecameInactive(page: page1)
        reloadController.updateSettings(settings: settings)
        wait(for: [page1.reloadExpectation!], timeout: 3)
    }

    func testPageRefreshIntervalTimerUpdatedOnSettingsUpdate() throws {
        page1.reloadExpectation = expectation(description: "page 1 was updated 4 times after settings update twice")
        page1.reloadExpectation!.expectedFulfillmentCount = 4
        page1.reloadExpectation!.assertForOverFulfill = false
        reloadController.pageBecameInactive(page: page1)
        reloadController.updateSettings(settings: settings)
        let delay = DispatchTime.now() + DispatchTimeInterval.seconds(2)
        DispatchQueue.global().asyncAfter(deadline: delay) {
            self.reloadController.updateSettings(settings: self.settings)
        }
        wait(for: [page1.reloadExpectation!], timeout: 5)
    }

    func testPageGetsRefreshIntervalUpdate() throws {
        reloadController.updateSettings(settings: settings)
        page2.reloadExpectation = expectation(description: "page 2 was updated 2 times adding with existing settings")
        page2.reloadExpectation!.expectedFulfillmentCount = 2
        page2.reloadExpectation!.assertForOverFulfill = false
        reloadController.pageBecameInactive(page: page2)
        wait(for: [page2.reloadExpectation!], timeout: 3)
    }

    func testRemovedPageIsNoLongerUpdated() throws {
        reloadController.updateSettings(settings: settings)
        page2.reloadExpectation = expectation(description: "page 2 was updated 2 times adding with existing settings")
        page2.reloadExpectation!.expectedFulfillmentCount = 2
        page2.reloadExpectation!.assertForOverFulfill = false
        reloadController.pageBecameInactive(page: page2)
        wait(for: [page2.reloadExpectation!], timeout: 3)
        page2.reloadExpectation = expectation(description: "page 2 was removed and does not receive updates anymore")
        page2.reloadExpectation!.isInverted = true
        reloadController.removePage(page: page2)
        wait(for: [page2.reloadExpectation!], timeout: 3)
    }

    func testActivePageIsNotUpdated() throws {
        reloadController.updateSettings(settings: settings)
        page2.reloadExpectation = expectation(description: "page 2 is active and should not be updated")
        page2.reloadExpectation!.isInverted = true
        reloadController.pageBecameActive(page: page2)
        wait(for: [page2.reloadExpectation!], timeout: 3)
    }

    func testDisabledRuleIsNotApplied() throws {
        reloadController.updateSettings(settings: settings)
        page3.reloadExpectation = expectation(description: "page 3 is disabled in settings and should not be reloaded")
        page3.reloadExpectation!.isInverted = true
        reloadController.pageBecameInactive(page: page3)
        wait(for: [page3.reloadExpectation!], timeout: 3)
    }

    func testInactivePageTimerIsNotUpdated() throws {
        reloadController.updateSettings(settings: settings)
        page4.reloadExpectation = expectation(description: "page 4 timer should not be recreated as it is already running")
        page4.reloadExpectation!.assertForOverFulfill = false
        reloadController.pageBecameInactive(page: page4)
        let delay = DispatchTime.now() + DispatchTimeInterval.seconds(3)
        DispatchQueue.global().asyncAfter(deadline: delay) {
            self.reloadController.pageBecameInactive(page: self.page4)
        }
        wait(for: [page4.reloadExpectation!], timeout: 6)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
