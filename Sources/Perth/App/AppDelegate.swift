import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let petStateManager = PetStateManager()
        let settings = AppSettings.shared
        let detector = SensitiveDataDetector()
        let notifier = AlertNotifier()
        let monitor = ClipboardMonitor(
            detector: detector,
            petStateManager: petStateManager,
            notifier: notifier,
            settings: settings
        )

        statusBarController = StatusBarController(
            petStateManager: petStateManager,
            monitor: monitor,
            settings: settings
        )

        monitor.startMonitoring()
    }
}
