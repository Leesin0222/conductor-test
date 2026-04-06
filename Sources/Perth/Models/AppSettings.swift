import Foundation
import Combine

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var isMonitoringEnabled: Bool {
        didSet { UserDefaults.standard.set(isMonitoringEnabled, forKey: "isMonitoringEnabled") }
    }

    @Published var checkInterval: Double {
        didSet { UserDefaults.standard.set(checkInterval, forKey: "checkInterval") }
    }

    @Published var enabledPatterns: Set<PatternType> {
        didSet {
            let raw = enabledPatterns.map { $0.rawValue }
            UserDefaults.standard.set(raw, forKey: "enabledPatterns")
        }
    }

    private init() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: "isMonitoringEnabled") == nil {
            defaults.set(true, forKey: "isMonitoringEnabled")
        }
        if defaults.object(forKey: "checkInterval") == nil {
            defaults.set(3.0, forKey: "checkInterval")
        }

        self.isMonitoringEnabled = defaults.bool(forKey: "isMonitoringEnabled")
        self.checkInterval = defaults.double(forKey: "checkInterval")

        if let raw = defaults.stringArray(forKey: "enabledPatterns") {
            self.enabledPatterns = Set(raw.compactMap { PatternType(rawValue: $0) })
        } else {
            self.enabledPatterns = Set(PatternType.allCases)
        }
    }
}
