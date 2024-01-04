//
//  RuleEditorView.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 21.8.2021.
//

import Foundation
import SwiftUI

import ExtensionSettings
import NonLinearSlider

struct RuleEditorView: View {
    @Binding var rule: Rule
    @State var rulePattern: String
    @State var ruleRefreshInterval: Double
    @State var isEditingSlider = false
    let refreshIntervalFormatter = RefreshIntervalFormatter()

    var body: some View {
        HStack {
            CheckBoxView(checked: $rule.enabled)
            Group {
                TextField("e.g. apple.com", text: self.$rulePattern, onCommit: {
                    self.rule.pattern = self.rulePattern
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300.0)
                Spacer()
                    .frame(width: 20, height: 0, alignment: .leading)
                Text(refreshIntervalFormatter.string(for: self.ruleRefreshInterval) ?? "-")
                    .foregroundColor(rule.enabled ? Color(NSColor.controlTextColor) : Color(NSColor.disabledControlTextColor))
                    .frame(width: 200.0, alignment: .leading)
                Spacer()
                    .frame(width: 20, height: 0, alignment: .leading)
                NonLinearSlider(value: self.$ruleRefreshInterval, type: .parabolic) { _ in } onSubmit: {
                    self.rule.refreshInterval = self.ruleRefreshInterval
                }
            }
            .disabled(!rule.enabled)
        }
    }
}
