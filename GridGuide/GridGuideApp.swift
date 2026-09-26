//
//  GridGuideApp.swift
//  GridGuide
//
//  Created by Tao Wang on 14/2/2024.
//

import AppKit
import Carbon.HIToolbox
import Combine
import SwiftUI

@main
struct GridGuideApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Overlay panels and the menu bar item are managed by AppDelegate. An empty Settings
        // scene satisfies SwiftUI without opening a window.
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = GridSettings()
    private var overlayController: OverlayController?
    private var hotKey: GlobalHotKey?
    private var statusItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        overlayController = OverlayController(settings: settings)
        // Control-Option-Command-G avoids clashing with Find Next (Command-G) in other apps.
        hotKey = GlobalHotKey(
            keyCode: UInt32(kVK_ANSI_G),
            modifiers: UInt32(controlKey | optionKey | cmdKey)
        ) { [weak self] in
            self?.toggleGridVisibility()
        }
        setupStatusItem()
    }

    private func setupStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "squareshape.split.3x3", accessibilityDescription: "Grid Guide")
            button.image?.isTemplate = true
        }

        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "", action: #selector(toggleGridVisibility), keyEquivalent: "g")
        toggleItem.keyEquivalentModifierMask = [.control, .option, .command]
        toggleItem.target = self
        menu.addItem(toggleItem)
        menu.addItem(.separator())

        let gridSizeRow = makeSliderItem(
            value: settings.gridSize,
            range: GridSettings.gridSizeRange,
            action: #selector(gridSizeSliderChanged(_:))
        )
        menu.addItem(gridSizeRow.item)

        let opacityRow = makeSliderItem(
            value: settings.opacity,
            range: GridSettings.opacityRange,
            action: #selector(opacitySliderChanged(_:))
        )
        menu.addItem(opacityRow.item)

        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        self.statusItem = statusItem

        settings.$isVisible
            .sink { toggleItem.title = $0 ? "Hide Grid" : "Show Grid" }
            .store(in: &cancellables)
        settings.$gridSize
            .sink { gridSizeRow.label.stringValue = "\(Int($0))" }
            .store(in: &cancellables)
        settings.$opacity
            .sink { opacityRow.label.stringValue = String(format: "%.2f", $0) }
            .store(in: &cancellables)
    }

    private func makeSliderItem(
        value: Double,
        range: ClosedRange<Double>,
        action: Selector
    ) -> (item: NSMenuItem, label: NSTextField) {
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 40))

        let slider = NSSlider(
            value: value,
            minValue: range.lowerBound,
            maxValue: range.upperBound,
            target: self,
            action: action
        )
        slider.isContinuous = true
        slider.frame = NSRect(x: 20, y: 10, width: 130, height: 20)

        let label = NSTextField(labelWithString: "")
        label.frame = NSRect(x: 160, y: 10, width: 36, height: 20)

        containerView.addSubview(slider)
        containerView.addSubview(label)

        let item = NSMenuItem()
        item.view = containerView
        return (item, label)
    }

    @objc private func toggleGridVisibility() {
        settings.isVisible.toggle()
    }

    @objc private func gridSizeSliderChanged(_ sender: NSSlider) {
        settings.gridSize = sender.doubleValue.rounded()
    }

    @objc private func opacitySliderChanged(_ sender: NSSlider) {
        settings.opacity = sender.doubleValue
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
