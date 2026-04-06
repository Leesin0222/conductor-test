import AppKit
import Carbon.HIToolbox

class KeyboardShortcutHandler {
    private var monitor: Any?

    func register(settings: AppSettings, petStateManager: PetStateManager) {
        // ⌘+Shift+P to toggle monitoring
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags == [.command, .shift] && event.keyCode == UInt16(kVK_ANSI_P) {
                DispatchQueue.main.async {
                    settings.isMonitoringEnabled.toggle()
                    petStateManager.setSleeping(!settings.isMonitoringEnabled)
                }
            }
        }
    }

    deinit {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
