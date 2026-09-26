//
//  OverlayController.swift
//  GridGuide
//

import AppKit
import Combine
import SwiftUI

/// Owns one click-through overlay panel per connected display and keeps them in sync with
/// display configuration changes and the visibility setting.
final class OverlayController {
    private let settings: GridSettings
    private var panels: [NSPanel] = []
    private var cancellables = Set<AnyCancellable>()

    init(settings: GridSettings) {
        self.settings = settings

        // Fires on display connect/disconnect, resolution changes and Dock/menu bar layout changes.
        NotificationCenter.default
            .publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in self?.rebuildPanels() }
            .store(in: &cancellables)

        settings.$isVisible
            .removeDuplicates()
            .sink { [weak self] isVisible in self?.updateVisibility(isVisible) }
            .store(in: &cancellables)

        rebuildPanels()
    }

    private func rebuildPanels() {
        panels.forEach { $0.close() }
        panels = NSScreen.screens.map(makePanel(for:))
        updateVisibility(settings.isVisible)
    }

    private func updateVisibility(_ isVisible: Bool) {
        for panel in panels {
            if isVisible {
                panel.orderFrontRegardless()
            } else {
                panel.orderOut(nil)
            }
        }
    }

    private func makePanel(for screen: NSScreen) -> NSPanel {
        let panel = NSPanel(
            contentRect: screen.visibleFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        panel.contentView = NSHostingView(rootView: GridGuideView(settings: settings))
        panel.setFrame(screen.visibleFrame, display: false)
        return panel
    }
}
