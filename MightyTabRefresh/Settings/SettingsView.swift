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
                   index < self.rules.count-1 {
                    RuleEditorView(rule: self.$rules[index],
                                   rulePattern: rule.pattern,
                                   ruleRefreshInterval: rule.refreshInterval)
                    Spacer()
                        .frame(width: 50, height: 0, alignment: .leading)
                    DeleteItemButtonView {
                        self.rules.removeAll { existingRule in
                            existingRule.id == rule.id
                        }
                    }
                }
            }
        }
    }
}

struct NoRulesView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Press \"+\" to add your first rule for some domain and interval to update. After extension is activated in Safari, pages need to be reloaded to start timer and start handling rules changes.")
                    .foregroundColor(Color(NSColor.disabledControlTextColor))
                Spacer()
            }
            Spacer()
        }
    }
}

struct SettingsView: View {
    @Binding var extensionSettings: ExtensionSettings

    var body: some View {
        List {
            if self.extensionSettings.rules.count <= 1 {
                NoRulesView()
            } else {
                RulesListView(rules: self.$extensionSettings.rules)
            }
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
                Rule(enabled: false, pattern: "radio-t.com", refreshInterval: 42.0)
            ])))
                .environment(\.colorScheme, .light)
            SettingsView(extensionSettings: .constant(ExtensionSettings(rules: [
                Rule(enabled: true, pattern: "apple.com", refreshInterval: 1.0),
                Rule(enabled: true, pattern: "ya.ru", refreshInterval: 5.0),
                Rule(enabled: false, pattern: "radio-t.com", refreshInterval: 42.0)
            ])))
                .environment(\.colorScheme, .dark)
            SettingsView(extensionSettings: .constant(ExtensionSettings(rules: [
            ])))
                .environment(\.colorScheme, .light)
            SettingsView(extensionSettings: .constant(ExtensionSettings(rules: [
                Rule(enabled: false, pattern: "radio-t.com", refreshInterval: 42.0)
            ])))
                .environment(\.colorScheme, .light)
        }
    }
}
