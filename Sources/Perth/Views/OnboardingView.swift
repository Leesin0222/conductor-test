import SwiftUI

struct OnboardingView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var petStateManager: PetStateManager
    @State private var page = 0

    var body: some View {
        VStack(spacing: 16) {
            if page == 0 {
                welcomePage
            } else if page == 1 {
                petSelectPage
            } else {
                featurePage
            }

            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(i == page ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            if page < 2 {
                Button("다음") { withAnimation { page += 1 } }
                    .buttonStyle(.borderedProminent)
            } else {
                Button("시작하기!") {
                    settings.hasCompletedOnboarding = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
    }

    private var welcomePage: some View {
        VStack(spacing: 12) {
            Text("🛡️")
                .font(.system(size: 64))
            Text("Perth에 오신 걸 환영해요!")
                .font(.title2)
                .fontWeight(.bold)
            Text("클립보드를 실시간으로 감시해서\n민감한 정보가 복사되면 알려드려요.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var petSelectPage: some View {
        VStack(spacing: 12) {
            Text("펫을 골라주세요!")
                .font(.title3)
                .fontWeight(.bold)

            HStack(spacing: 16) {
                ForEach(PetCharacter.allCases) { character in
                    Button(action: { petStateManager.character = character }) {
                        VStack(spacing: 4) {
                            Text(character.emoji(for: .happy))
                                .font(.system(size: 40))
                            Text(character.label)
                                .font(.caption)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(petStateManager.character == character
                                      ? Color.accentColor.opacity(0.2) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("나중에 설정에서 바꿀 수 있어요")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var featurePage: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("이런 걸 감지해요")
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)

            featureRow(icon: "key.fill", text: "API 키, 토큰")
            featureRow(icon: "lock.fill", text: "비밀번호")
            featureRow(icon: "creditcard.fill", text: "신용카드 번호")
            featureRow(icon: "person.text.rectangle.fill", text: "주민등록번호")
            featureRow(icon: "key.horizontal.fill", text: "SSH/RSA 개인 키")
            featureRow(icon: "star.fill", text: "직접 만든 커스텀 패턴")

            Text("⌘+Shift+P로 감시를 켜고 끌 수 있어요")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.accentColor)
            Text(text)
                .font(.subheadline)
        }
    }
}
