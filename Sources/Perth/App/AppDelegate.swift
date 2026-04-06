import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var shortcutHandler: KeyboardShortcutHandler!
    private var screenShareDetector: ScreenShareDetector!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let petStateManager = PetStateManager()
        let settings = AppSettings.shared
        let detector = SensitiveDataDetector()
        let customPatternManager = CustomPatternManager()
        detector.customPatternManager = customPatternManager
        let notifier = AlertNotifier()
        let monitor = ClipboardMonitor(
            detector: detector,
            petStateManager: petStateManager,
            notifier: notifier,
            settings: settings
        )

        screenShareDetector = ScreenShareDetector()
        screenShareDetector.startMonitoring()

        statusBarController = StatusBarController(
            petStateManager: petStateManager,
            monitor: monitor,
            settings: settings,
            customPatternManager: customPatternManager,
            screenShareDetector: screenShareDetector
        )

        shortcutHandler = KeyboardShortcutHandler()
        shortcutHandler.register(settings: settings, petStateManager: petStateManager)

        monitor.startMonitoring()
    }
}
