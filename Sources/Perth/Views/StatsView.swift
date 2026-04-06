import SwiftUI

struct StatsView: View {
    @ObservedObject var stats: DetectionStats
    @ObservedObject var safetyStreak: SafetyStreak

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("통계")
                    .font(.headline)
                    .fontWeight(.semibold)

                // Summary cards
                HStack(spacing: 8) {
                    StatCard(title: "오늘", value: "\(stats.todayCount)", color: .blue)
                    StatCard(title: "이번 주", value: "\(stats.weekCount)", color: .orange)
                    StatCard(title: "안전 기록", value: "\(safetyStreak.currentStreakDays)일", color: .green)
                }

                if let top = stats.topPatternThisWeek {
                    HStack {
                        Image(systemName: top.icon)
                            .foregroundColor(.orange)
                        Text("이번 주 가장 많이 감지: \(top.rawValue)")
                            .font(.caption)
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.orange.opacity(0.1)))
                }

                Divider()

                // Daily bar chart
                Text("최근 7일")
                    .font(.subheadline)
                    .fontWeight(.medium)

                BarChart(stats: recentDays)

                Divider()

                // Export
                Button(action: exportReport) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("리포트 내보내기 (JSON)")
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            .padding(12)
        }
    }

    private var recentDays: [(String, Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        let calendar = Calendar.current

        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "yyyy-MM-dd"
            let key = dayFormatter.string(from: date)
            let count = stats.dailyStats.first(where: { $0.id == key })?.count ?? 0
            return (formatter.string(from: date), count)
        }
    }

    private func exportReport() {
        let json = stats.exportJSON()
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "perth-report.json"
        panel.allowedContentTypes = [.json]
        if panel.runModal() == .OK, let url = panel.url {
            try? json.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.08)))
    }
}

struct BarChart: View {
    let stats: [(String, Int)]

    private var maxValue: Int {
        max(stats.map(\.1).max() ?? 1, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(stats, id: \.0) { label, count in
                VStack(spacing: 4) {
                    Text("\(count)")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(count > 0 ? Color.orange : Color.green.opacity(0.3))
                        .frame(height: max(CGFloat(count) / CGFloat(maxValue) * 60, 4))
                    Text(label)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 90)
    }
}
