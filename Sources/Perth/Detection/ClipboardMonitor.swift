import AppKit
import Combine

@MainActor
class ClipboardMonitor: ObservableObject {
    @Published var recentAlerts: [SensitiveDataMatch] = []

    private let detector: SensitiveDataDetector
    private let petStateManager: PetStateManager
    private let notifier: AlertNotifier
    private let settings: AppSettings
    let safetyStreak: SafetyStreak
    let historyManager: ClipboardHistoryManager
    let stats: DetectionStats
    private var timer: Timer?
    private var autoClearTimer: Timer?
    private var lastChangeCount: Int = 0

    init(detector: SensitiveDataDetector, petStateManager: PetStateManager,
         notifier: AlertNotifier, settings: AppSettings) {
        self.detector = detector
        self.petStateManager = petStateManager
        self.notifier = notifier
        self.settings = settings
        self.safetyStreak = SafetyStreak()
        self.historyManager = ClipboardHistoryManager()
        self.stats = DetectionStats()
        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    func startMonitoring() {
        stopMonitoring()
        timer = Timer.scheduledTimer(withTimeInterval: settings.checkInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.checkClipboard()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func clearAlerts() {
        recentAlerts.removeAll()
    }

    func deleteAlert(_ alert: SensitiveDataMatch) {
        recentAlerts.removeAll { $0.id == alert.id }
    }

    func clearClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString("", forType: .string)
        lastChangeCount = NSPasteboard.general.changeCount
    }

    private func checkClipboard() {
        guard settings.isMonitoringEnabled else { return }

        let currentCount = NSPasteboard.general.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        if let bundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier {
            if settings.excludedApps.contains(where: { bundleId.lowercased().contains($0.lowercased()) }) {
                return
            }
        }

        guard let text = NSPasteboard.general.string(forType: .string),
              !text.isEmpty else { return }

        let matches = detector.scan(text: text, enabledPatterns: settings.enabledPatterns)
        guard !matches.isEmpty else { return }

        let patternTypes = matches.map { $0.patternType }

        recentAlerts.insert(contentsOf: matches, at: 0)
        if recentAlerts.count > 50 {
            recentAlerts = Array(recentAlerts.prefix(50))
        }
        petStateManager.triggerAlert()
        safetyStreak.recordAlert()
        historyManager.record(patterns: patternTypes)
        stats.record(patterns: matches)

        if let topMatch = matches.max(by: { $0.severity < $1.severity }) {
            notifier.sendAlert(match: topMatch, settings: settings)
        }

        if settings.autoClearEnabled {
            autoClearTimer?.invalidate()
            autoClearTimer = Timer.scheduledTimer(withTimeInterval: settings.autoClearDelay, repeats: false) { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.clearClipboard()
                }
            }
        }
    }
}
