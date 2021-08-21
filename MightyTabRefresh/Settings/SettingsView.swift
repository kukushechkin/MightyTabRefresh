//
//  SettingsView.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 20.7.2021.
//

import Foundation
import SwiftUI
import ExtensionSettings

struct RulesListView: View {
    @Binding var rules: [Rule]
    
    var body: some View {
        ForEach(self.rules, id: \.id) { rule in
            HStack {
                if let index = self.rules.firstIndex(of: rule),
                   index < self.rules.count {
                    RuleEditorView(rule: self.$rules[index],
                                   rulePattern: rule.pattern)
                    Spacer()
                        .frame(width: 50, height: 0, alignment: .leading)
                    DeleteItemButtonView {
                        self.rules.removeAll { r in
                            r.id == rule.id
                        }
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    @Binding var extensionSettings: ExtensionSettings
    
    var body: some View {
        List {
            RulesListView(rules: self.$extensionSettings.rules)
        }
        .toolbar {
            Button(action: add) { Label("", systemImage: "plus") }
        }
    }
    
    func add() {
        self.extensionSettings.add()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SettingsView(extensionSettings: .constant(ExtensionSettings(rules: [
                Rule(enabled: true, pattern: "apple.com", refreshInterval: 1.0),
                Rule(enabled: true, pattern: "ya.ru", refreshInterval: 5.0),
                Rule(enabled: false, pattern: "radio-t.com", refreshInterval: 42.0),
            ])))
                .environment(\.colorScheme, .light)
            SettingsView(extensionSettings: .constant(ExtensionSettings(rules: [
                Rule(enabled: true, pattern: "apple.com", refreshInterval: 1.0),
                Rule(enabled: true, pattern: "ya.ru", refreshInterval: 5.0),
                Rule(enabled: false, pattern: "radio-t.com", refreshInterval: 42.0),
            ])))
                .environment(\.colorScheme, .dark)
        }
    }
}
