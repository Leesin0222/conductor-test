import SwiftUI

struct PetView: View {
    @ObservedObject var petStateManager: PetStateManager
    @ObservedObject var safetyStreak: SafetyStreak
    @State private var bounceOffset: CGFloat = 0
    @State private var isShaking = false

    var body: some View {
        VStack(spacing: 6) {
            Text(petStateManager.currentEmoji)
                .font(.system(size: 64))
                .offset(y: bounceOffset)
                .rotationEffect(isShaking ? .degrees(5) : .degrees(0))
                .animation(
                    isShaking
                        ? .easeInOut(duration: 0.1).repeatCount(6, autoreverses: true)
                        : .default,
                    value: isShaking
                )

            SpeechBubble(text: petStateManager.state.message)

            Text(safetyStreak.streakMessage)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .onChange(of: petStateManager.state) { _, newState in
            switch newState {
            case .alert:
                isShaking = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isShaking = false
                }
            case .happy:
                withAnimation(.easeInOut(duration: 0.5).repeatCount(2, autoreverses: true)) {
                    bounceOffset = -8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    bounceOffset = 0
                }
            default:
                break
            }
        }
    }
}

struct SpeechBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.controlBackgroundColor))
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
            )
    }
}
