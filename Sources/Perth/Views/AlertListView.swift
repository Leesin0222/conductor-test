import SwiftUI

// Groups consecutive alerts of the same PatternType
struct AlertGroup: Identifiable {
    let id = UUID()
    let patternType: PatternType
    let alerts: [SensitiveDataMatch]

    var count: Int { alerts.count }
    var isGrouped: Bool { count > 1 }
    var first: SensitiveDataMatch { alerts[0] }
    var severity: Severity { patternType.severity }
}

private func groupAlerts(_ alerts: [SensitiveDataMatch]) -> [AlertGroup] {
    guard !alerts.isEmpty else { return [] }
    var groups: [AlertGroup] = []
    var current: [SensitiveDataMatch] = [alerts[0]]

    for i in 1..<alerts.count {
        if alerts[i].patternType == current[0].patternType {
            current.append(alerts[i])
        } else {
            groups.append(AlertGroup(patternType: current[0].patternType, alerts: current))
            current = [alerts[i]]
        }
    }
    groups.append(AlertGroup(patternType: current[0].patternType, alerts: current))
    return groups
}

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
                        ForEach(groupAlerts(alerts)) { group in
                            if group.isGrouped {
                                AlertGroupRow(group: group, onDelete: onDelete)
                            } else {
                                AlertRow(alert: group.first, onDelete: onDelete)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct AlertGroupRow: View {
    let group: AlertGroup
    var onDelete: ((SensitiveDataMatch) -> Void)?
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Group header
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(severityColor)
                        .frame(width: 3, height: 36)

                    Image(systemName: group.patternType.icon)
                        .font(.system(size: 14))
                        .foregroundColor(severityColor)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(group.patternType.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                            SeverityBadge(severity: group.severity)
                            Text("\(group.count)건")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(severityColor.opacity(0.7)))
                        }
                        Text(group.first.matchedSnippet)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    Text(timeAgo(group.first.timestamp))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: isExpanded ? 0 : 8)
                    .fill(severityColor.opacity(severityBackgroundOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: isExpanded ? 0 : 8)
                    .stroke(severityColor.opacity(0.2), lineWidth: 1)
            )

            // Expanded items
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(group.alerts) { alert in
                        HStack(spacing: 8) {
                            Spacer().frame(width: 3)
                            Spacer().frame(width: 24)

                            Text(alert.matchedSnippet)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.secondary)
                                .lineLimit(1)

                            Spacer()

                            if let onDelete {
                                Button {
                                    onDelete(alert)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                                .help("이 알림 삭제")
                            }

                            Text(timeAgo(alert.timestamp))
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)

                        if alert.id != group.alerts.last?.id {
                            Divider().padding(.leading, 35)
                        }
                    }
                }
                .background(severityColor.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(severityColor.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var severityColor: Color {
        switch group.severity {
        case .high: return .red
        case .medium: return .orange
        case .low: return .yellow
        }
    }

    private var severityBackgroundOpacity: Double {
        switch group.severity {
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

struct AlertRow: View {
    let alert: SensitiveDataMatch
    var onDelete: ((SensitiveDataMatch) -> Void)?

    var body: some View {
        HStack(spacing: 8) {
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
