import AppKit
import Combine

struct ClipboardEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let sourceApp: String
    let sourceBundleId: String
    let detectedPatterns: [PatternType]
}

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
        DispatchQueue.main.async {
            self.entries.insert(entry, at: 0)
            if self.entries.count > self.maxEntries {
                self.entries = Array(self.entries.prefix(self.maxEntries))
            }
        }
    }
}
