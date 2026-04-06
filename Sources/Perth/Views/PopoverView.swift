import SwiftUI

enum PopoverTab: String, CaseIterable {
    case alerts = "알림"
    case history = "히스토리"
    case stats = "통계"
    case patterns = "패턴"
    case settings = "설정"

    var icon: String {
        switch self {
        case .alerts: return "bell.fill"
        case .history: return "clock.fill"
        case .stats: return "chart.bar.fill"
        case .patterns: return "star.fill"
        case .settings: return "gearshape"
        }
    }
}

struct PopoverView: View {
    @ObservedObject var petStateManager: PetStateManager
    @ObservedObject var monitor: ClipboardMonitor
    @ObservedObject var settings: AppSettings
    @ObservedObject var customPatternManager: CustomPatternManager
    @ObservedObject var screenShareDetector: ScreenShareDetector
    @State private var selectedTab: PopoverTab = .alerts

    init(petStateManager: PetStateManager, monitor: ClipboardMonitor,
         settings: AppSettings, customPatternManager: CustomPatternManager,
         screenShareDetector: ScreenShareDetector) {
        self.petStateManager = petStateManager
        self.monitor = monitor
        self.settings = settings
        self.customPatternManager = customPatternManager
        self.screenShareDetector = screenShareDetector
    }

    var body: some View {
        VStack(spacing: 0) {
            if !settings.hasCompletedOnboarding {
                OnboardingView(settings: settings, petStateManager: petStateManager)
            } else {
                // Screen share warning
                if screenShareDetector.isScreenBeingShared {
                    HStack(spacing: 6) {
                        Image(systemName: "eye.trianglebadge.exclamationmark")
                            .foregroundColor(.red)
                        Text("화면 공유/녹화 감지! 주의하세요!")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.red)
                    }
                    .padding(6)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                }

                PetView(petStateManager: petStateManager, safetyStreak: monitor.safetyStreak)
                    .frame(height: 140)

                Divider()

                // Tab content
                Group {
                    switch selectedTab {
                    case .alerts:
                        AlertListView(
                            alerts: monitor.recentAlerts,
                            onClear: { monitor.clearAlerts() },
                            onClearClipboard: { monitor.clearClipboard() },
                            onDelete: { alert in monitor.deleteAlert(alert) }
                        )
                    case .history:
                        HistoryView(historyManager: monitor.historyManager)
                    case .stats:
                        StatsView(stats: monitor.stats, safetyStreak: monitor.safetyStreak)
                    case .patterns:
                        CustomPatternsView(manager: customPatternManager)
                    case .settings:
                        SettingsView(settings: settings, petStateManager: petStateManager)
                    }
                }

                Divider()

                // Bottom tab bar
                HStack(spacing: 0) {
                    ForEach(PopoverTab.allCases, id: \.self) { tab in
                        Button(action: { selectedTab = tab }) {
                            VStack(spacing: 2) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 12))
                                Text(tab.rawValue)
                                    .font(.system(size: 9))
                            }
                            .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 6)

                Divider()

                // Status bar
                HStack {
                    Text(settings.isMonitoringEnabled ? "감시 중 (⌘⇧P)" : "중단됨 (⌘⇧P)")
                        .font(.caption)
                        .foregroundColor(settings.isMonitoringEnabled ? .green : .secondary)

                    Circle()
                        .fill(settings.isMonitoringEnabled ? Color.green : Color.gray)
                        .frame(width: 6, height: 6)

                    Spacer()

                    Button("종료") { NSApp.terminate(nil) }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
        }
        .frame(width: 320, height: 520)
    }
}
