import AppKit
import SwiftUI
import Combine

class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var cancellables = Set<AnyCancellable>()

    init(petStateManager: PetStateManager, monitor: ClipboardMonitor,
         settings: AppSettings, customPatternManager: CustomPatternManager,
         screenShareDetector: ScreenShareDetector) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 520)
        popover.behavior = .transient

        let contentView = PopoverView(
            petStateManager: petStateManager,
            monitor: monitor,
            settings: settings,
            customPatternManager: customPatternManager,
            screenShareDetector: screenShareDetector
        )
        popover.contentViewController = NSHostingController(rootView: contentView)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "shield.lefthalf.filled", accessibilityDescription: "Perth")
            button.image?.isTemplate = true
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Update icon when alert is active
        petStateManager.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let button = self?.statusItem.button else { return }
                switch state {
                case .alert:
                    button.image = NSImage(systemSymbolName: "shield.lefthalf.filled.trianglebadge.exclamationmark", accessibilityDescription: "Alert")
                    button.image?.isTemplate = true
                case .sleeping:
                    button.image = NSImage(systemSymbolName: "shield.slash", accessibilityDescription: "Sleeping")
                    button.image?.isTemplate = true
                default:
                    button.image = NSImage(systemSymbolName: "shield.lefthalf.filled", accessibilityDescription: "Perth")
                    button.image?.isTemplate = true
                }
            }
            .store(in: &cancellables)
    }

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
