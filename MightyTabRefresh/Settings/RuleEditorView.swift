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
    @State var rulePattern: String
    
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
                Slider(value: $rule.refreshInterval, in: 10...3600) {
                    Text("update every \(Int(rule.refreshInterval)) sec")
                        .foregroundColor(rule.enabled ? Color(NSColor.controlTextColor) : Color(NSColor.disabledControlTextColor))
                }
                
            }
            .disabled(!rule.enabled)
        }
    }
}
