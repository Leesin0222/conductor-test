import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyManager: ClipboardHistoryManager
    @State private var searchText: String = ""

    private var filteredEntries: [ClipboardEntry] {
        guard !searchText.isEmpty else { return historyManager.entries }
        let query = searchText.lowercased()
        return historyManager.entries.filter { entry in
            entry.sourceApp.lowercased().contains(query)
            || entry.sourceBundleId.lowercased().contains(query)
            || entry.detectedPatterns.contains(where: { $0.rawValue.lowercased().contains(query) })
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("클립보드 히스토리")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(filteredEntries.count)건")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Search bar
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                TextField("앱 이름, 패턴 유형 검색", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(RoundedRectangle(cornerRadius: 6).fill(Color(.controlBackgroundColor)))
            .padding(.horizontal, 12)
            .padding(.bottom, 4)

            if filteredEntries.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: searchText.isEmpty ? "clock" : "magnifyingglass")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "아직 기록이 없어요" : "검색 결과가 없어요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(filteredEntries) { entry in
                            HistoryRow(entry: entry)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
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
