import AppKit

class AlertNotifier {
    private var lastNotificationTime: Date = .distantPast
    private let cooldown: TimeInterval = 10

    func sendAlert(match: SensitiveDataMatch) {
        let now = Date()
        guard now.timeIntervalSince(lastNotificationTime) >= cooldown else { return }
        lastNotificationTime = now

        let title = "🙀 민감한 정보 감지!"
        let body = "\(match.patternType.rawValue)이(가) 클립보드에서 발견되었어요. 조심하세요!"

        // NSUserNotification works without an .app bundle (unlike UNUserNotificationCenter)
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
}
