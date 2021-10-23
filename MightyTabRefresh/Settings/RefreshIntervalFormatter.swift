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
                return self.secondsString(count: UInt(interval))
            }
            if interval < 3600 {
                return self.minutesString(count: UInt(interval)/60)
            }
            return self.hoursString(count: UInt(interval)/60/60)
        }
        return nil
    }

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        true
    }

    private func secondsString(count: UInt) -> String {
        let formatString : String = NSLocalizedString("refresh every %d seconds", comment: "refresh every %d seconds")
        let resultString : String = String.localizedStringWithFormat(formatString, count)
        return resultString
    }

    private func minutesString(count: UInt) -> String {
        let formatString : String = NSLocalizedString("refresh every %d minutes", comment: "refresh every %d minutes")
        let resultString : String = String.localizedStringWithFormat(formatString, count)
        return resultString
    }

    private func hoursString(count: UInt) -> String {
        let formatString : String = NSLocalizedString("refresh every %d hours", comment: "refresh every %d hours")
        let resultString : String = String.localizedStringWithFormat(formatString, count)
        return resultString
    }
}
