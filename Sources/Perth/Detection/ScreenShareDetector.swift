import AppKit
import CoreGraphics

class ScreenShareDetector: ObservableObject {
    @Published var isScreenBeingShared = false
    private var timer: Timer?

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.check()
        }
        check()
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func check() {
        // Check if any screen recording/sharing sessions are active
        // CGWindowListCopyWindowInfo can detect screen capture overlays
        let sharing = isScreenCaptureActive()
        DispatchQueue.main.async {
            self.isScreenBeingShared = sharing
        }
    }

    private func isScreenCaptureActive() -> Bool {
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
