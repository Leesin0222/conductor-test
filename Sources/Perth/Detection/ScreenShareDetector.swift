import AppKit
import CoreGraphics

@MainActor
class ScreenShareDetector: ObservableObject {
    @Published var isScreenBeingShared = false
    private var timer: Timer?

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.check()
            }
        }
        check()
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func check() {
        isScreenBeingShared = isScreenCaptureActive()
    }

    private nonisolated func isScreenCaptureActive() -> Bool {
        guard let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else {
            return false
        }

        let captureApps = [
            "screencaptureui", "screensharing", "zoom.us",
            "com.apple.screencaptureui", "com.apple.screensharing",
            "us.zoom.xos", "com.microsoft.teams", "com.discord",
            "com.webex.meetingmanager",
        ]

        for window in windowList {
            if let owner = window[kCGWindowOwnerName as String] as? String {
                let lower = owner.lowercased()
                if captureApps.contains(where: { lower.contains($0) }) {
                    return true
                }
            }
        }
        return false
    }
}
