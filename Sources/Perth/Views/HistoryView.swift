import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyManager: ClipboardHistoryManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("클립보드 히스토리")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                if historyManager.entries.isEmpty {
                    VStack(spacing: 8) {
                        Spacer()
                        Image(systemName: "clock")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary)
                        Text("아직 기록이 없어요")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 120)
                } else {
                    LazyVStack(spacing: 4) {
                        ForEach(historyManager.entries) { entry in
                            HistoryRow(entry: entry)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
    }
}

struct HistoryRow: View {
    let entry: ClipboardEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "app.fill")
                .font(.system(size: 14))
                .foregroundColor(.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.sourceApp)
                    .font(.system(size: 12, weight: .semibold))
                HStack(spacing: 4) {
                    ForEach(entry.detectedPatterns, id: \.self) { type in
                        Image(systemName: type.icon)
                            .font(.system(size: 9))
                            .foregroundColor(.orange)
                    }
                    Text(entry.sourceBundleId)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(timeAgo(entry.timestamp))
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "방금" }
        if seconds < 3600 { return "\(seconds / 60)분 전" }
        if seconds < 86400 { return "\(seconds / 3600)시간 전" }
        return "\(seconds / 86400)일 전"
    }
}
