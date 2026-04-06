import AppKit
import Combine

class ClipboardMonitor: ObservableObject {
    @Published var recentAlerts: [SensitiveDataMatch] = []

    private let detector: SensitiveDataDetector
    private let petStateManager: PetStateManager
    private let notifier: AlertNotifier
    private let settings: AppSettings
    private var timer: Timer?
    private var lastChangeCount: Int = 0

    init(detector: SensitiveDataDetector, petStateManager: PetStateManager,
         notifier: AlertNotifier, settings: AppSettings) {
        self.detector = detector
        self.petStateManager = petStateManager
        self.notifier = notifier
        self.settings = settings
        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    func startMonitoring() {
        stopMonitoring()
        timer = Timer.scheduledTimer(withTimeInterval: settings.checkInterval, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    func clearAlerts() {
        recentAlerts.removeAll()
    }

    private func checkClipboard() {
        guard settings.isMonitoringEnabled else { return }

        let currentCount = NSPasteboard.general.changeCount
        guard currentCount != lastChangeCount else { return }
        lastChangeCount = currentCount

        guard let text = NSPasteboard.general.string(forType: .string),
              !text.isEmpty else { return }

        let matches = detector.scan(text: text, enabledPatterns: settings.enabledPatterns)
        guard !matches.isEmpty else { return }

        DispatchQueue.main.async { [weak self] in
            self?.recentAlerts.insert(contentsOf: matches, at: 0)
            if let self = self, self.recentAlerts.count > 50 {
                self.recentAlerts = Array(self.recentAlerts.prefix(50))
            }
            self?.petStateManager.triggerAlert()
        }

        if let topMatch = matches.max(by: { $0.severity < $1.severity }) {
            notifier.sendAlert(match: topMatch)
        }
    }
}
