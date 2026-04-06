import AppKit
import Carbon.HIToolbox

@MainActor
class KeyboardShortcutHandler {
    private var monitor: Any?

    func register(settings: AppSettings, petStateManager: PetStateManager) {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak settings, weak petStateManager] event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags == [.command, .shift] && event.keyCode == UInt16(kVK_ANSI_P) {
                DispatchQueue.main.async { @MainActor in
                    settings?.isMonitoringEnabled.toggle()
                    if let settings = settings {
                        petStateManager?.setSleeping(!settings.isMonitoringEnabled)
                    }
                }
            }
        }
    }

    func cleanup() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
