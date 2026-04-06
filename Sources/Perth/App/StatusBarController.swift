import AppKit
import SwiftUI
import Combine

@MainActor
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
            button.title = petStateManager.currentEmoji
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Update icon when pet state, character, or today's count changes
        petStateManager.$state
            .combineLatest(petStateManager.$character, monitor.stats.$dailyStats)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _, _ in
                guard let self = self else { return }
                let emoji = petStateManager.currentEmoji
                let todayCount = monitor.stats.todayCount
                if todayCount > 0 {
                    self.statusItem.button?.title = "\(emoji)\(todayCount)"
                } else {
                    self.statusItem.button?.title = emoji
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

    func showPopover() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
