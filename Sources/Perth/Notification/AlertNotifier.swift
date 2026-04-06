import AppKit

class AlertNotifier {
    private var lastNotificationTime: Date = .distantPast
    private let cooldown: TimeInterval = 10

    func sendAlert(match: SensitiveDataMatch, settings: AppSettings) {
        let now = Date()
        guard now.timeIntervalSince(lastNotificationTime) >= cooldown else { return }
        lastNotificationTime = now

        let title = "🙀 민감한 정보 감지!"
        let body = "\(match.displayName)이(가) 클립보드에서 발견되었어요. 조심하세요!"

        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body

        switch settings.alertSoundMode {
        case .normal:
            notification.soundName = NSUserNotificationDefaultSoundName
        case .byLevel:
            switch match.severity {
            case .high:
                notification.soundName = "Sosumi"
            case .medium:
                notification.soundName = "Purr"
            case .low:
                notification.soundName = "Pop"
            }
        case .silent:
            break
        }

        NSUserNotificationCenter.default.deliver(notification)
    }
}
