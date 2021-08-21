//
//  DeleteButtonView.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 21.8.2021.
//

import Foundation
import SwiftUI

struct DeleteItemButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            self.action()
        } label: {
            Label("", systemImage: "minus.circle.fill")
                .labelStyle(IconOnlyLabelStyle())
                .foregroundColor(Color(NSColor(named: "DeleteButtonLabelColor")!))
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
