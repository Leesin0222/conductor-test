import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("설정")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)

                Toggle("클립보드 감시", isOn: $settings.isMonitoringEnabled)
                    .font(.subheadline)

                VStack(alignment: .leading, spacing: 4) {
                    Text("감시 주기: \(String(format: "%.0f", settings.checkInterval))초")
                        .font(.subheadline)
                    Slider(value: $settings.checkInterval, in: 1...10, step: 1)
                }

                Divider()

                Text("감지 패턴")
                    .font(.subheadline)
                    .fontWeight(.medium)

                ForEach(PatternType.allCases) { type in
                    Toggle(isOn: patternBinding(for: type)) {
                        HStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.system(size: 12))
                                .frame(width: 18)
                            Text(type.rawValue)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .padding(12)
        }
    }

    private func patternBinding(for type: PatternType) -> Binding<Bool> {
        Binding(
            get: { settings.enabledPatterns.contains(type) },
            set: { enabled in
                if enabled {
                    settings.enabledPatterns.insert(type)
                } else {
                    settings.enabledPatterns.remove(type)
                }
            }
        )
    }
}
