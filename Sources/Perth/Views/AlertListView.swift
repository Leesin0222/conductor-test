import SwiftUI

struct AlertListView: View {
    let alerts: [SensitiveDataMatch]
    let onClear: () -> Void
    let onClearClipboard: () -> Void
    var onDelete: ((SensitiveDataMatch) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("최근 알림")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                if !alerts.isEmpty {
                    Button(action: onClearClipboard) {
                        HStack(spacing: 3) {
                            Image(systemName: "clipboard")
                                .font(.system(size: 10))
                            Text("클립보드 비우기")
                        }
                    }
                    .font(.caption)
                    .buttonStyle(.plain)
                    .foregroundColor(.red)

                    Button("모두 지우기", action: onClear)
                        .font(.caption)
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            if alerts.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                    Text("클립보드가 안전해요!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(alerts) { alert in
                            AlertRow(alert: alert,
                                     onClearClipboard: onClearClipboard,
                                     onDelete: onDelete)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct AlertRow: View {
    let alert: SensitiveDataMatch
    let onClearClipboard: () -> Void
    var onDelete: ((SensitiveDataMatch) -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            // Severity indicator bar
            RoundedRectangle(cornerRadius: 2)
                .fill(severityColor)
                .frame(width: 3, height: 36)

            Image(systemName: alert.patternType.icon)
                .font(.system(size: 14))
                .foregroundColor(severityColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(alert.displayName)
                        .font(.system(size: 12, weight: .semibold))
                    SeverityBadge(severity: alert.severity)
                }
                Text(alert.matchedSnippet)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if let onDelete {
                Button {
                    onDelete(alert)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("이 알림 삭제")
            }

            Text(timeAgo(alert.timestamp))
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(severityColor.opacity(severityBackgroundOpacity))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(severityColor.opacity(0.2), lineWidth: 1)
        )
    }

    private var severityColor: Color {
        switch alert.severity {
        case .high: return .red
        case .medium: return .orange
        case .low: return .yellow
        }
    }

    private var severityBackgroundOpacity: Double {
        switch alert.severity {
        case .high: return 0.12
        case .medium: return 0.08
        case .low: return 0.06
        }
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "방금" }
        if seconds < 3600 { return "\(seconds / 60)분 전" }
        if seconds < 86400 { return "\(seconds / 3600)시간 전" }
        return "\(seconds / 86400)일 전"
    }
}

struct SeverityBadge: View {
    let severity: Severity

    var body: some View {
        Text(label)
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(
                Capsule().fill(color)
            )
    }

    private var label: String {
        switch severity {
        case .high: return "HIGH"
        case .medium: return "MED"
        case .low: return "LOW"
        }
    }

    private var color: Color {
        switch severity {
        case .high: return .red
        case .medium: return .orange
        case .low: return .yellow
        }
    }
}
