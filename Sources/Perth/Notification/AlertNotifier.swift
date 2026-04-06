import AppKit
import UserNotifications

@MainActor
class AlertNotifier: NSObject, @preconcurrency UNUserNotificationCenterDelegate {
    private var lastNotificationTime: Date = .distantPast
    private let cooldown: TimeInterval = 10
    private var useModernAPI = false
    var onNotificationClicked: (() -> Void)?

    override init() {
        super.init()
        if Bundle.main.bundleIdentifier != nil,
           Bundle.main.bundlePath.hasSuffix(".app") {
            useModernAPI = true
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
            center.delegate = self
        }
    }

    func sendAlert(match: SensitiveDataMatch, settings: AppSettings) {
        let now = Date()
        guard now.timeIntervalSince(lastNotificationTime) >= cooldown else { return }
        lastNotificationTime = now

        let title = "🙀 민감한 정보 감지!"
        let body = "\(match.displayName)이(가) 클립보드에서 발견되었어요. 조심하세요!"

        if useModernAPI {
            sendModernNotification(title: title, body: body, match: match, settings: settings)
        } else {
            if #unavailable(macOS 14.0) {
                sendLegacyNotification(title: title, body: body, match: match, settings: settings)
            }
        }
    }

    // MARK: - Modern API (UNUserNotificationCenter, requires .app bundle)

    private func sendModernNotification(title: String, body: String,
                                         match: SensitiveDataMatch, settings: AppSettings) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.threadIdentifier = match.patternType.rawValue

        if settings.alertSoundMode != .silent {
            content.sound = .default
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - UNUserNotificationCenterDelegate (notification click)

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.onNotificationClicked?()
        }
        completionHandler()
    }

    // Show notification even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    // MARK: - Legacy API (NSUserNotification, for swift run without bundle)

    @available(macOS, deprecated: 11.0)
    private func sendLegacyNotification(title: String, body: String,
                                         match: SensitiveDataMatch, settings: AppSettings) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body

        switch settings.alertSoundMode {
        case .normal:
            notification.soundName = NSUserNotificationDefaultSoundName
        case .byLevel:
            switch match.severity {
            case .high:   notification.soundName = "Sosumi"
            case .medium: notification.soundName = "Purr"
            case .low:    notification.soundName = "Pop"
            }
        case .silent:
            break
        }

        NSUserNotificationCenter.default.deliver(notification)
    }
}
