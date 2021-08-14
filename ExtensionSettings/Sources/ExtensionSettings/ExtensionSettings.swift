import Foundation

public struct Rule: Codable {
    public let id: UUID
    public let enabled: Bool
    public var pattern: String
    public let refreshInterval: TimeInterval
    
    public init(enabled: Bool, pattern: String, refreshInterval: TimeInterval) {
        self.id = UUID()
        self.enabled = enabled
        self.pattern = pattern
        self.refreshInterval = refreshInterval
    }
}

/// Used to transfer urls and refresh times from the app to the extension.
public struct ExtensionSettings: Codable {
    public static let settingsMessageName = "com.kukushechkin.MightyTabRefresh.settingsMessage"
    public static let settingsMessageKey = "com.kukushechkin.MightyTabRefresh.settings"
    
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
