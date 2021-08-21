//
//  RuleEditorView.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 21.8.2021.
//

import Foundation
import SwiftUI

import ExtensionSettings

struct RuleEditorView: View {
    @Binding var rule: Rule
    
    var body: some View {
        HStack {
            CheckBoxView(checked: $rule.enabled)
            Group {
                TextField("rule pattern", text: $rule.pattern)
                    .padding(.leading, 15)
                    .if(rule.enabled) { view in
                        view
                        .cursorOnHover(cursor: .iBeam)
                        .backgroundOnHover()
                    }
                Divider()
                Slider(value: $rule.refreshInterval, in: 10...3600) {
                    // TODO: time interval formatter
                    Text("update every \(Int(rule.refreshInterval)) sec")
                        .foregroundColor(rule.enabled ? Color(NSColor.controlTextColor) : Color(NSColor.disabledControlTextColor))
                }
            }
            .disabled(!rule.enabled)
        }
    }
}
