//
//  SettingsView.swift
//  MightyTabRefresh
//
//  Created by Kukushkin, Vladimir on 20.7.2021.
//

import Foundation
import SwiftUI
import ExtensionSettings

struct SettingsView: View {
    @Binding var extensionSettings: ExtensionSettings
    
    var body: some View {
        VStack {
            List {
                ForEach(self.extensionSettings.rules.indexed(), id: \.1.id) { index, rule in
                    HStack {
                        RuleEditorView(rule: self.$extensionSettings.rules[index])
                        Spacer()
                            .frame(width: 100, height: 0, alignment: .leading)
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
