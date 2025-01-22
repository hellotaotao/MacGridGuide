//
//  GridGuideApp.swift
//  GridGuide
//
//  Created by Tao Wang on 14/2/2024.
//

import SwiftUI
import AppKit
import NotificationCenter
import Foundation

@main
struct GridGuideApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        DispatchQueue.main.async {
            NSApp.windows.forEach { window in
                window.backgroundColor = .clear
                window.isOpaque = false
                window.level = .floating
                window.ignoresMouseEvents = true
                window.setFrame(NSScreen.main?.visibleFrame ?? .zero, display: true)
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.hasShadow = false
                window.styleMask = []  // Remove all window decorations
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            GridGuideView()
        }
        .windowStyle(.hiddenTitleBar)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var valueLabel: NSTextField!
    @objc dynamic var gridSize: Double = 50 {
        didSet {        
            NotificationCenter.default.post(
                name: NSNotification.Name("gridDensityChanged"), 
                object: nil,
                userInfo: ["value": gridSize]
            )
            valueLabel?.stringValue = "\(Int(gridSize))"
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.setupStatusItem()
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "squareshape.split.3x3", accessibilityDescription: nil)
            button.image?.isTemplate = true
        }
        let menu = NSMenu()
        
        // Add slider item with label
        let menuItem = NSMenuItem()
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 40))
        
        let slider = NSSlider(value: gridSize, 
                            minValue: 40, 
                            maxValue: 100, 
                            target: self, 
                            action: #selector(sliderChanged(_:)))
        slider.frame = NSRect(x: 20, y: 10, width: 130, height: 20)
        
        valueLabel = NSTextField(frame: NSRect(x: 160, y: 10, width: 30, height: 20))
        valueLabel.isEditable = false
        valueLabel.isBordered = false
        valueLabel.backgroundColor = .clear
        valueLabel.stringValue = "\(Int(gridSize))"
        
        containerView.addSubview(slider)
        containerView.addSubview(valueLabel)
        
        menuItem.view = containerView
        menu.addItem(menuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func sliderChanged(_ sender: NSSlider) {
        gridSize = round(sender.doubleValue)
    }
}
