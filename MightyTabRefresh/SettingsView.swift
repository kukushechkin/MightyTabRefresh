//
//  SettingsView.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 20.7.2021.
//

import Foundation
import SwiftUI
import ExtensionSettings

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

struct RuleEditorView: View {
    @Binding var rule: Rule
    
    var body: some View {
        HStack {
            CheckBoxView(checked: $rule.enabled)
            Group {
                TextField("rule", text: $rule.pattern)
                TextField("interval", value: $rule.refreshInterval, formatter: NumberFormatter())
            }
            .disabled(!rule.enabled)
        }
    }
}

struct SettingsView: View {
    @Binding var extensionSettings: ExtensionSettings
    
    var body: some View {
        VStack {
            List {
                ForEach(self.extensionSettings.rules.indexed(), id: \.1.id) { index, rule in
                    HStack {
                        RuleEditorView(rule: self.$extensionSettings.rules[index])
                        DeleteItemButtonView {
                            self.delete(at: IndexSet(integer: index))
                        }
                    }
                }
            }
            .toolbar {
                Button(action: add) { Label("", systemImage: "plus") }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        self.extensionSettings.rules.remove(atOffsets: offsets)
    }
    
    func add() {
        self.extensionSettings.rules.append(Rule.defaultRule())
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
