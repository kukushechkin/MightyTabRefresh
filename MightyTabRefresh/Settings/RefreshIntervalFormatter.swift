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
                return "update every \(Int(interval)) secs"
            }
            if interval < 3600 {
                return "update every \(Int(interval)/60) mins"
            }
            return "update every \(Int(interval)/60/60) hours"
        }
        return nil
    }

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        true
    }
}
