import Foundation

public struct Rule: Codable {
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
}

/// Used to transfer urls and refresh times from the app to the extension.
public struct ExtensionSettings: Codable {
    public static let settingsMessageName = "com.kukushechkin.MightyTabRefresh.settingsMessage"
    public static let settingsMessageKey = "com.kukushechkin.MightyTabRefresh.settingsMessage.settings"
    public static let reloadCommandMessageName = "com.kukushechkin.MightyTabRefresh.reloadMessage"
    public static let reloadCommandMessageKey = "com.kukushechkin.MightyTabRefresh.reloadMessage.hosts"
    public static let scriptBecameActiveMessageKey = "com.kukushechkin.MightyTabRefresh.scriptBecameAvailable"
    
    public var rules: [Rule] = []
    
    public init(rules: [Rule]) {
        self.rules = rules
    }
}

// Safari App Extension protocol dictionary encoding
public extension ExtensionSettings {
    init?(from json: Any) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
              let decoded = try? JSONDecoder().decode(ExtensionSettings.self, from: jsonData) else {
            return nil
        }
        self = decoded
    }
    
    func encode() throws -> Any {
        let jsonData = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
    }
}
