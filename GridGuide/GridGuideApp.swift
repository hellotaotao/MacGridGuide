//
//  GridGuideApp.swift
//  GridGuide
//
//  Created by Tao Wang on 14/2/2024.
//

import AppKit
import SwiftUI

@main
struct GridGuideApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Overlay panels, the menu bar item and the settings window are managed by AppDelegate.
        // An empty Settings scene satisfies SwiftUI without opening a window.
        Settings {
            EmptyView()
        }
        .commands {
            // Route Command-comma to the AppKit-managed settings window instead of the empty scene.
            CommandGroup(replacing: .appSettings) {
                Button("Settings…") { appDelegate.showSettings() }
                    .keyboardShortcut(",")
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let settings = GridSettings()
    private var overlayController: OverlayController?
    private var shortcutManager: ShortcutManager?
    private var settingsWindowController: SettingsWindowController?
    private var statusItem: NSStatusItem?
    private weak var opacityLabel: NSTextField?

    func applicationDidFinishLaunching(_ notification: Notification) {
        overlayController = OverlayController(settings: settings)
        let shortcutManager = ShortcutManager(settings: settings) { [weak self] action in
            self?.perform(action)
        }
        self.shortcutManager = shortcutManager
        settingsWindowController = SettingsWindowController(settings: settings, shortcutManager: shortcutManager)
        setupStatusItem()

        if !settings.hasSeenWelcome {
            showSettings()
        }
    }

    /// Opening the app again from Finder or Launchpad shows the settings window, since an agent
    /// app has no Dock icon or window to bring forward.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings()
        return false
    }

    func showSettings() {
        settingsWindowController?.show()
    }

    private func perform(_ action: ShortcutAction) {
        switch action {
        case .toggleGrid: settings.isVisible.toggle()
        case .nextPreset: settings.selectNextPreset()
        }
    }

    // MARK: Status item

    private func setupStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "squareshape.split.3x3", accessibilityDescription: "Grid Guide")
            button.image?.isTemplate = true
        }

        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
        self.statusItem = statusItem
    }

    /// Rebuilds the menu each time it opens so titles, presets and shortcuts are always current.
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        let toggleItem = makeItem(
            title: settings.isVisible ? "Hide Grid" : "Show Grid",
            action: #selector(toggleGridVisibility),
            shortcut: settings.shortcuts[.toggleGrid]
        )
        menu.addItem(toggleItem)
        menu.addItem(.separator())

        let header = NSMenuItem(title: "Layouts", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        for (index, preset) in settings.presets.enumerated() {
            let item = makeItem(title: preset.name, action: #selector(selectPreset(_:)))
            item.tag = index
            item.state = preset.id == settings.activePresetID ? .on : .off
            menu.addItem(item)
        }
        menu.addItem(makeItem(
            title: "Next Layout",
            action: #selector(selectNextPreset),
            shortcut: settings.shortcuts[.nextPreset]
        ))
        menu.addItem(.separator())

        menu.addItem(makeOpacityItem())
        menu.addItem(.separator())

        menu.addItem(makeItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(makeItem(title: "About Grid Guide", action: #selector(showAbout)))
        menu.addItem(.separator())
        menu.addItem(makeItem(title: "Quit Grid Guide", action: #selector(quit), keyEquivalent: "q"))
    }

    private func makeItem(
        title: String,
        action: Selector,
        keyEquivalent: String = "",
        shortcut: Shortcut? = nil
    ) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: shortcut?.menuKeyEquivalent ?? keyEquivalent)
        if let shortcut {
            item.keyEquivalentModifierMask = shortcut.menuModifierMask
        }
        item.target = self
        return item
    }

    private func makeOpacityItem() -> NSMenuItem {
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 240, height: 30))

        let title = NSTextField(labelWithString: "Opacity")
        title.frame = NSRect(x: 20, y: 6, width: 56, height: 18)

        let slider = NSSlider(
            value: settings.opacity,
            minValue: GridSettings.opacityRange.lowerBound,
            maxValue: GridSettings.opacityRange.upperBound,
            target: self,
            action: #selector(opacitySliderChanged(_:))
        )
        slider.isContinuous = true
        slider.frame = NSRect(x: 78, y: 5, width: 112, height: 20)

        let label = NSTextField(labelWithString: Self.percentString(settings.opacity))
        label.alignment = .right
        label.frame = NSRect(x: 192, y: 6, width: 38, height: 18)
        opacityLabel = label

        containerView.addSubview(title)
        containerView.addSubview(slider)
        containerView.addSubview(label)

        let item = NSMenuItem()
        item.view = containerView
        return item
    }

    private static func percentString(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    // MARK: Actions

    @objc private func toggleGridVisibility() {
        settings.isVisible.toggle()
    }

    @objc private func selectPreset(_ sender: NSMenuItem) {
        guard settings.presets.indices.contains(sender.tag) else { return }
        settings.selectPreset(settings.presets[sender.tag].id)
    }

    @objc private func selectNextPreset() {
        settings.selectNextPreset()
    }

    @objc private func opacitySliderChanged(_ sender: NSSlider) {
        settings.opacity = sender.doubleValue
        opacityLabel?.stringValue = Self.percentString(sender.doubleValue)
    }

    @objc private func openSettings() {
        showSettings()
    }

    @objc private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
