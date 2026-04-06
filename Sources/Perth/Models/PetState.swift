import Foundation
import Combine

enum PetCharacter: String, CaseIterable, Identifiable, Sendable {
    case cat, dog, rabbit, bear

    var id: String { rawValue }

    var label: String {
        switch self {
        case .cat: return "고양이"
        case .dog: return "강아지"
        case .rabbit: return "토끼"
        case .bear: return "곰"
        }
    }

    func emoji(for state: PetState) -> String {
        switch (self, state) {
        case (.cat, .happy):    return "🐱"
        case (.cat, .sleeping): return "😺"
        case (.cat, .alert):    return "🙀"
        case (.cat, .worried):  return "😿"
        case (.dog, .happy):    return "🐶"
        case (.dog, .sleeping): return "🐕"
        case (.dog, .alert):    return "🐕‍🦺"
        case (.dog, .worried):  return "🐩"
        case (.rabbit, .happy):    return "🐰"
        case (.rabbit, .sleeping): return "🐇"
        case (.rabbit, .alert):    return "🐰"
        case (.rabbit, .worried):  return "🐇"
        case (.bear, .happy):    return "🐻"
        case (.bear, .sleeping): return "🧸"
        case (.bear, .alert):    return "🐻‍❄️"
        case (.bear, .worried):  return "🧸"
        }
    }
}

enum PetState: String, CaseIterable, Sendable {
    case happy
    case sleeping
    case alert
    case worried

    var emoji: String {
        switch self {
        case .happy: return "🐱"
        case .sleeping: return "😺"
        case .alert: return "🙀"
        case .worried: return "😿"
        }
    }

    var message: String {
        switch self {
        case .happy: return "클립보드 안전해요!"
        case .sleeping: return "감시 중단 중이에요..."
        case .alert: return "위험한 정보 발견!"
        case .worried: return "조심하세요...!"
        }
    }
}

@MainActor
class PetStateManager: ObservableObject {
    @Published var state: PetState = .happy
    @Published var character: PetCharacter {
        didSet { UserDefaults.standard.set(character.rawValue, forKey: "petCharacter") }
    }
    private var cooldownTimer: Timer?
    private var timeOfDayTimer: Timer?
    private weak var settings: AppSettings?

    var currentEmoji: String {
        character.emoji(for: state)
    }

    init(settings: AppSettings? = nil) {
        self.settings = settings
        if let raw = UserDefaults.standard.string(forKey: "petCharacter"),
           let saved = PetCharacter(rawValue: raw) {
            self.character = saved
        } else {
            self.character = .cat
        }
        startTimeOfDayUpdates()
    }

    func triggerAlert() {
        state = .alert
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.updateForTimeOfDay()
            }
        }
    }

    func setSleeping(_ sleeping: Bool) {
        if sleeping {
            cooldownTimer?.invalidate()
            state = .sleeping
        } else {
            updateForTimeOfDay()
        }
    }

    private func startTimeOfDayUpdates() {
        updateForTimeOfDay()
        timeOfDayTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self = self, self.state != .alert else { return }
                self.updateForTimeOfDay()
            }
        }
    }

    private func updateForTimeOfDay() {
        let hour = Calendar.current.component(.hour, from: Date())
        let sleepHour = settings?.petSleepHour ?? 23
        let wakeHour = settings?.petWakeHour ?? 6

        let isSleeping: Bool
        if sleepHour > wakeHour {
            // Normal: e.g. wake=6, sleep=23 → sleeping when hour >= 23 OR hour < 6
            isSleeping = hour >= sleepHour || hour < wakeHour
        } else {
            // Inverted: e.g. wake=22, sleep=6 (night owl) → sleeping when hour >= 6 AND hour < 22
            isSleeping = hour >= sleepHour && hour < wakeHour
        }

        state = isSleeping ? .sleeping : .happy
    }
}
