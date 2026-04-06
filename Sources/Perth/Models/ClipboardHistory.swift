import AppKit
import Combine

struct ClipboardEntry: Identifiable, Sendable {
    let id = UUID()
    let timestamp: Date
    let sourceApp: String
    let sourceBundleId: String
    let detectedPatterns: [PatternType]
}

@MainActor
class ClipboardHistoryManager: ObservableObject {
    @Published var entries: [ClipboardEntry] = []
    private let maxEntries = 100

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
    }
}
