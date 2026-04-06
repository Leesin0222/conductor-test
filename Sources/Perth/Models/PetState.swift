import Foundation
import Combine

enum PetState: String, CaseIterable {
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

class PetStateManager: ObservableObject {
    @Published var state: PetState = .happy
    private var cooldownTimer: Timer?

    func triggerAlert() {
        state = .alert
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.state = .happy
            }
        }
    }

    func setSleeping(_ sleeping: Bool) {
        if sleeping {
            cooldownTimer?.invalidate()
            state = .sleeping
        } else {
            state = .happy
        }
    }
}
