import Foundation
import Combine

enum AlertSoundMode: String, CaseIterable {
    case normal = "기본"
    case byLevel = "위험도별"
    case silent = "무음"
}

@MainActor
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

    @Published var autoClearEnabled: Bool {
        didSet { UserDefaults.standard.set(autoClearEnabled, forKey: "autoClearEnabled") }
    }

    @Published var autoClearDelay: Double {
        didSet { UserDefaults.standard.set(autoClearDelay, forKey: "autoClearDelay") }
    }

    @Published var excludedApps: [String] {
        didSet { UserDefaults.standard.set(excludedApps, forKey: "excludedApps") }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            LaunchAtLoginHelper.set(enabled: launchAtLogin)
        }
    }

    @Published var alertSoundMode: AlertSoundMode {
        didSet { UserDefaults.standard.set(alertSoundMode.rawValue, forKey: "alertSoundMode") }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    private init() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: "isMonitoringEnabled") == nil {
            defaults.set(true, forKey: "isMonitoringEnabled")
        }
        if defaults.object(forKey: "checkInterval") == nil {
            defaults.set(3.0, forKey: "checkInterval")
        }
        if defaults.object(forKey: "autoClearDelay") == nil {
            defaults.set(5.0, forKey: "autoClearDelay")
        }

        self.isMonitoringEnabled = defaults.bool(forKey: "isMonitoringEnabled")
        self.checkInterval = defaults.double(forKey: "checkInterval")
        self.autoClearEnabled = defaults.bool(forKey: "autoClearEnabled")
        self.autoClearDelay = defaults.double(forKey: "autoClearDelay")
        self.launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        self.hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
        self.excludedApps = defaults.stringArray(forKey: "excludedApps") ?? [
            "com.apple.keychainaccess",  // 키체인 접근
            "com.apple.Passwords",       // 암호 앱 (macOS Sequoia+)
        ]

        if let raw = defaults.string(forKey: "alertSoundMode"),
           let mode = AlertSoundMode(rawValue: raw) {
            self.alertSoundMode = mode
        } else {
            self.alertSoundMode = .normal
        }

        if let raw = defaults.stringArray(forKey: "enabledPatterns") {
            self.enabledPatterns = Set(raw.compactMap { PatternType(rawValue: $0) })
        } else {
            self.enabledPatterns = Set(PatternType.allCases)
        }
    }
}
