//
//  SettingsView.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 20.7.2021.
//

import Foundation
import SwiftUI
import ExtensionSettings

struct RuleEditorView: View {
    @Binding var rule: Rule
    
    var body: some View {
        HStack {
            Text("Pattern:")
            TextField("rule", text: $rule.pattern)
        }
    }
}

struct SettingsView: View {
    @Binding var extensionSettings: ExtensionSettings
    
    var body: some View {
        VStack {
            VStack {
                Text("Settings:")
                Divider()
                ForEach(self.extensionSettings.rules.indexed(), id: \.1.id) { index, rule in
                    RuleEditorView(rule: self.$extensionSettings.rules[index])
                }
            }
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(extensionSettings: .constant(ExtensionSettings(rules: [
            Rule(enabled: true, pattern: "apple.com", refreshInterval: 1.0),
            Rule(enabled: true, pattern: "ya.ru", refreshInterval: 5.0),
        ])))
    }
}
