//
//  SafariPageWrapper.swift
//  SafariPage
//
//  Created by Kukushkin, Vladimir on 8.9.2021.
//

import Foundation
import SafariServices

protocol SafariPageWrapperProtocol: Hashable {
    var host: String { get }
    func reload()
}

struct SafariPageWrapper: SafariPageWrapperProtocol {
    let page: SFSafariPage
    var host: String { page.host }

    func reload() {
        page.reload()
    }
}
