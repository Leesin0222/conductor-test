import AppKit
import SwiftUI
import Combine

class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var cancellables = Set<AnyCancellable>()

    init(petStateManager: PetStateManager, monitor: ClipboardMonitor, settings: AppSettings) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 440)
        popover.behavior = .transient

        let contentView = PopoverView(
            petStateManager: petStateManager,
            monitor: monitor,
            settings: settings
        )
        popover.contentViewController = NSHostingController(rootView: contentView)

        if let button = statusItem.button {
            button.title = petStateManager.state.emoji
            button.action = #selector(togglePopover)
            button.target = self
        }

        petStateManager.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.statusItem.button?.title = state.emoji
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
