import AppKit
import Combine

struct ClipboardEntry: Identifiable, Codable, Sendable {
    let id: UUID
    let timestamp: Date
    let sourceApp: String
    let sourceBundleId: String
    let detectedPatterns: [PatternType]

    init(timestamp: Date, sourceApp: String, sourceBundleId: String, detectedPatterns: [PatternType]) {
        self.id = UUID()
        self.timestamp = timestamp
        self.sourceApp = sourceApp
        self.sourceBundleId = sourceBundleId
        self.detectedPatterns = detectedPatterns
    }
}

@MainActor
class ClipboardHistoryManager: ObservableObject {
    @Published var entries: [ClipboardEntry] = []
    private let maxEntries = 100
    private let key = "clipboardHistory"
    private var todayCutoff: Date {
        Calendar.current.startOfDay(for: Date())
    }

    init() {
        load()
    }

    func record(patterns: [PatternType]) {
        let frontmost = NSWorkspace.shared.frontmostApplication
        let entry = ClipboardEntry(
            timestamp: Date(),
            sourceApp: frontmost?.localizedName ?? "알 수 없음",
            sourceBundleId: frontmost?.bundleIdentifier ?? "",
            detectedPatterns: patterns
        )
        entries.insert(entry, at: 0)
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
        save()
    }

    func pruneExpired() {
        entries.removeAll { $0.timestamp < todayCutoff }
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let loaded = try? JSONDecoder().decode([ClipboardEntry].self, from: data) else { return }
        entries = loaded.filter { $0.timestamp >= todayCutoff }
    }
}
