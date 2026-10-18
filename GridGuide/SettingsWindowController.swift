//
//  SettingsWindowController.swift
//  GridGuide
//

import AppKit
import SwiftUI

/// Hosts `SettingsView` in a plain window. The SwiftUI `Settings` scene is hard to open reliably
/// from an agent app without a Dock icon, so the window is managed here instead.
final class SettingsWindowController {
    private let settings: GridSettings
    private let shortcutManager: ShortcutManager
    private var window: NSWindow?

    init(settings: GridSettings, shortcutManager: ShortcutManager) {
        self.settings = settings
        self.shortcutManager = shortcutManager
    }

    func show() {
        if window == nil {
            let hostingController = NSHostingController(
                rootView: SettingsView(settings: settings, shortcutManager: shortcutManager)
            )
            let window = NSWindow(contentViewController: hostingController)
            window.title = "Grid Guide Settings"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.center()
            self.window = window
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
