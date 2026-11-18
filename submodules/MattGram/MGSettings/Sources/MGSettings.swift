import Foundation

public extension Notification.Name {
    static let mattgramSettingsDidChange = Notification.Name("mattgramSettingsDidChange")
}

/// Хранилище настроек клиента MattGram. Ключи вида `mg_f<номер функции>`.
public final class MGSettings {
    public static let shared = MGSettings()

    private let defaults = UserDefaults.standard
    public static let prefix = "mg_"

    public func key(_ id: Int) -> String {
        return MGSettings.prefix + "f\(id)"
    }

    public func bool(_ key: String, default value: Bool = false) -> Bool {
        if defaults.object(forKey: key) == nil {
            return value
        }
        return defaults.bool(forKey: key)
    }

    public func setBool(_ key: String, _ value: Bool) {
        defaults.set(value, forKey: key)
        NotificationCenter.default.post(name: .mattgramSettingsDidChange, object: nil, userInfo: ["key": key])
    }

    public func isEnabled(feature id: Int, default value: Bool = false) -> Bool {
        return self.bool(self.key(id), default: value)
    }

    public func setEnabled(feature id: Int, _ value: Bool) {
        self.setBool(self.key(id), value)
    }

    /// Номер сборки (CFBundleVersion).
    public var buildNumber: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "0"
    }

    public var versionString: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "0"
    }

    // MARK: Резервная копия (JSON)

    public func exportJSON() -> String {
        var dict: [String: Any] = [:]
        for (k, v) in defaults.dictionaryRepresentation() where k.hasPrefix(MGSettings.prefix) {
            dict[k] = v
        }
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    @discardableResult
    public func importJSON(_ string: String) -> Int {
        guard let data = string.data(using: .utf8),
              let dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            return 0
        }
        var count = 0
        for (k, v) in dict where k.hasPrefix(MGSettings.prefix) {
            if let n = v as? NSNumber {
                defaults.set(n, forKey: k)
                count += 1
            } else if let s = v as? String {
                defaults.set(s, forKey: k)
                count += 1
            }
        }
        NotificationCenter.default.post(name: .mattgramSettingsDidChange, object: nil)
        return count
    }

    public func resetAll() {
        for (k, _) in defaults.dictionaryRepresentation() where k.hasPrefix(MGSettings.prefix) {
            defaults.removeObject(forKey: k)
        }
        NotificationCenter.default.post(name: .mattgramSettingsDidChange, object: nil)
    }
}
