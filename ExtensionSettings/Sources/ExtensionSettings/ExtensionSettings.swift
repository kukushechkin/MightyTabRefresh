import Foundation

public struct Rule: Codable, Identifiable, Equatable {
    public let id: UUID
    public var enabled: Bool
    public var pattern: String
    public var refreshInterval: TimeInterval

    public init(enabled: Bool, pattern: String, refreshInterval: TimeInterval) {
        self.id = UUID()
        self.enabled = enabled
        self.pattern = pattern
        self.refreshInterval = refreshInterval
    }

    public static func defaultRule() -> Rule {
        Rule(enabled: false, pattern: "", refreshInterval: 60.0)
    }

    public func matches(host: String) -> Bool {
        host.contains(self.pattern)
    }
}

// Used to transfer urls and refresh times from the app to the extension.
public struct ExtensionSettings: Codable {
    public var rules: [Rule] = []

    public init(rules: [Rule]) {
        // Workaround for ForEach List
        self.rules = rules + [Rule.defaultRule()]
    }
}

// Rules modification
public extension ExtensionSettings {
//    mutating func remove(rule: Rule) {
//        self.rules = self.rules.filter { r in
//            r.id != rule.id
//        }
//    }

    mutating func add(rule: Rule = Rule.defaultRule()) {
        self.rules += [rule]
    }
}

// Safari App Extension protocol dictionary encoding
public extension ExtensionSettings {
    init?(from json: Any) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
              let decoded = try? JSONDecoder().decode(ExtensionSettings.self, from: jsonData) else {
            return nil
        }
        self.rules = decoded.rules
    }

    func encode() throws -> Any {
        let jsonData = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
    }
}
