//
//  SFSafariPage+host.swift
//  SFSafariPage+host
//
//  Created by Kukushkin, Vladimir on 24.8.2021.
//

import Foundation
import SafariServices

fileprivate func syncAsync<T>(defaultError: T, body: (@escaping (T) -> Void) -> Void) -> T {
    var result: T = defaultError
    let group = DispatchGroup()
    group.enter()
    
    body {
        result = $0
        group.leave()
    }
    
    let _ = group.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(10))
    return result
}

public extension SFSafariPage {
    var host: String {
        get {
            syncAsync(defaultError: "") { done in
                self.getPropertiesWithCompletionHandler { properties in
                    if let host = properties?.url?.host {
                        done(host)
                        return
                    }
                    done("")
                }
            }
        }
    }
}
