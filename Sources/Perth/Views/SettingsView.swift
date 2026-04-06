import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var petStateManager: PetStateManager
    @State private var newExcludedApp: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("설정")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)

                // General
                Toggle("클립보드 감시", isOn: $settings.isMonitoringEnabled)
                    .font(.subheadline)

                Toggle("로그인 시 자동 실행", isOn: $settings.launchAtLogin)
                    .font(.subheadline)

                VStack(alignment: .leading, spacing: 4) {
                    Text("감시 주기: \(String(format: "%.0f", settings.checkInterval))초")
                        .font(.subheadline)
                    Slider(value: $settings.checkInterval, in: 1...10, step: 1)
                }

                Divider()

                // Sound
                VStack(alignment: .leading, spacing: 4) {
                    Text("알림 소리")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Picker("", selection: $settings.alertSoundMode) {
                        ForEach(AlertSoundMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Divider()

                // Auto-clear
                Toggle("민감 정보 감지 시 클립보드 자동 비우기", isOn: $settings.autoClearEnabled)
                    .font(.subheadline)

                if settings.autoClearEnabled {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("자동 비우기 대기: \(String(format: "%.0f", settings.autoClearDelay))초")
                            .font(.subheadline)
                        Slider(value: $settings.autoClearDelay, in: 1...30, step: 1)
                    }
                }

                Divider()

                // Pet character
                Text("펫 선택")
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 12) {
                    ForEach(PetCharacter.allCases) { character in
                        Button(action: { petStateManager.character = character }) {
                            VStack(spacing: 4) {
                                Text(character.emoji(for: .happy))
                                    .font(.system(size: 28))
                                Text(character.label)
                                    .font(.system(size: 10))
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(petStateManager.character == character
                                          ? Color.accentColor.opacity(0.2) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(petStateManager.character == character
                                            ? Color.accentColor : Color.clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Divider()

                // Pet schedule
                VStack(alignment: .leading, spacing: 4) {
                    Text("펫 활동 시간")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    HStack {
                        Text("기상")
                            .font(.system(size: 12))
                            .frame(width: 30)
                        Picker("", selection: $settings.petWakeHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d:00", hour)).tag(hour)
                            }
                        }
                        .frame(width: 80)

                        Spacer().frame(width: 16)

                        Text("취침")
                            .font(.system(size: 12))
                            .frame(width: 30)
                        Picker("", selection: $settings.petSleepHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d:00", hour)).tag(hour)
                            }
                        }
                        .frame(width: 80)
                    }

                    Text("현재: \(String(format: "%02d:00", settings.petWakeHour)) ~ \(String(format: "%02d:00", settings.petSleepHour)) 활동")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Divider()

                // Patterns
                Text("감지 패턴")
                    .font(.subheadline)
                    .fontWeight(.medium)

                ForEach(PatternType.allCases.filter { $0 != .custom }) { type in
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

                Divider()

                // Excluded apps
                Text("제외 앱 (Bundle ID)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                ForEach(settings.excludedApps, id: \.self) { app in
                    HStack {
                        Text(app)
                            .font(.system(size: 11, design: .monospaced))
                        Spacer()
                        Button(action: {
                            settings.excludedApps.removeAll { $0 == app }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack {
                    TextField("com.example.app", text: $newExcludedApp)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11))
                    Button(action: {
                        let trimmed = newExcludedApp.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        settings.excludedApps.append(trimmed)
                        newExcludedApp = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
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
