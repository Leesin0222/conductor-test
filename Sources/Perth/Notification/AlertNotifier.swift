import UserNotifications

class AlertNotifier {
    private var lastNotificationTime: Date = .distantPast
    private let cooldown: TimeInterval = 10

    func sendAlert(match: SensitiveDataMatch) {
        let now = Date()
        guard now.timeIntervalSince(lastNotificationTime) >= cooldown else { return }
        lastNotificationTime = now

        let content = UNMutableNotificationContent()
        content.title = "🙀 민감한 정보 감지!"
        content.body = "\(match.patternType.rawValue)이(가) 클립보드에서 발견되었어요. 조심하세요!"
        content.sound = .default
        content.threadIdentifier = match.patternType.rawValue

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
