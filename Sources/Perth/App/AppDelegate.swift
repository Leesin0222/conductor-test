import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var shortcutHandler: KeyboardShortcutHandler!
    private var screenShareDetector: ScreenShareDetector!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let settings = AppSettings.shared
        let petStateManager = PetStateManager(settings: settings)
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

        notifier.onNotificationClicked = { [weak self] in
            self?.statusBarController.showPopover()
        }

        shortcutHandler = KeyboardShortcutHandler()
        shortcutHandler.register(settings: settings, petStateManager: petStateManager)

        monitor.startMonitoring()
    }
}
