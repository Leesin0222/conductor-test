import SwiftUI

struct PopoverView: View {
    @ObservedObject var petStateManager: PetStateManager
    @ObservedObject var monitor: ClipboardMonitor
    @ObservedObject var settings: AppSettings
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            PetView(petStateManager: petStateManager)
                .frame(height: 140)

            Divider()

            if showSettings {
                SettingsView(settings: settings)
            } else {
                AlertListView(alerts: monitor.recentAlerts, onClear: {
                    monitor.clearAlerts()
                })
            }

            Divider()

            HStack {
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: showSettings ? "list.bullet" : "gearshape")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)

                Spacer()

                Text(settings.isMonitoringEnabled ? "감시 중" : "중단됨")
                    .font(.caption)
                    .foregroundColor(settings.isMonitoringEnabled ? .green : .secondary)

                Circle()
                    .fill(settings.isMonitoringEnabled ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)

                Spacer()

                Button("종료") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 320, height: 440)
    }
}
