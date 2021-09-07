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
                Spacer()
                    .frame(width: 50, height: 0, alignment: .leading)

                // TODO: more reasonable default value?
                Text(refreshIntervalFormatter.string(for: self.ruleRefreshInterval) ?? "-")
                    .foregroundColor(rule.enabled ? Color(NSColor.controlTextColor) : Color(NSColor.disabledControlTextColor))

                NonLinearSlider(value: self.$ruleRefreshInterval, type: .parabolic) { _ in } onSubmit: {
                    self.rule.refreshInterval = self.ruleRefreshInterval
                }
            }
            .disabled(!rule.enabled)
        }
    }
}
