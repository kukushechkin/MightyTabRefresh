//
//  RefreshIntervalFormatter.swift
//  RefreshIntervalFormatter
//
//  Created by Kukushkin, Vladimir on 2.9.2021.
//

import Foundation

class RefreshIntervalFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        if let interval = obj as? TimeInterval {
            if interval < 120 {
                return secondsString(count: UInt(interval))
            }
            if interval < 3600 {
                return minutesString(count: UInt(interval) / 60)
            }
            return hoursString(count: UInt(interval) / 60 / 60)
        }
        return nil
    }

    override func getObjectValue(_: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for _: String, errorDescription _: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        true
    }

    private func secondsString(count: UInt) -> String {
        let formatString: String = NSLocalizedString("refresh every %d seconds", comment: "refresh every %d seconds")
        let resultString = String.localizedStringWithFormat(formatString, count)
        return resultString
    }

    private func minutesString(count: UInt) -> String {
        let formatString: String = NSLocalizedString("refresh every %d minutes", comment: "refresh every %d minutes")
        let resultString = String.localizedStringWithFormat(formatString, count)
        return resultString
    }

    private func hoursString(count: UInt) -> String {
        let formatString: String = NSLocalizedString("refresh every %d hours", comment: "refresh every %d hours")
        let resultString = String.localizedStringWithFormat(formatString, count)
        return resultString
    }
}
