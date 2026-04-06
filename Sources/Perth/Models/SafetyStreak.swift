import Foundation
import Combine

@MainActor
class SafetyStreak: ObservableObject {
    @Published private(set) var currentStreakDays: Int = 0
    @Published private(set) var lastAlertDate: Date?

    init() {
        let defaults = UserDefaults.standard
        if let last = defaults.object(forKey: "lastAlertDate") as? Date {
            lastAlertDate = last
        }
        updateStreak()
    }

    func recordAlert() {
        lastAlertDate = Date()
        UserDefaults.standard.set(lastAlertDate, forKey: "lastAlertDate")
        updateStreak()
    }

    func updateStreak() {
        guard let last = lastAlertDate else {
            // Never had an alert — count from first launch
            let firstLaunch = UserDefaults.standard.object(forKey: "firstLaunchDate") as? Date ?? Date()
            if UserDefaults.standard.object(forKey: "firstLaunchDate") == nil {
                UserDefaults.standard.set(firstLaunch, forKey: "firstLaunchDate")
            }
            currentStreakDays = Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
            return
        }
        currentStreakDays = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
    }

    var streakMessage: String {
        if currentStreakDays == 0 {
            return "오늘 감지된 적 있어요"
        } else if currentStreakDays == 1 {
            return "1일째 안전해요!"
        } else {
            return "\(currentStreakDays)일째 안전해요! 🎉"
        }
    }
}
