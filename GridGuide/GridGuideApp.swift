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
    @objc dynamic var gridDensity: Double = 50 {
        didSet {        
            NotificationCenter.default.post(
                name: NSNotification.Name("gridDensityChanged"), 
                object: nil,
                userInfo: ["value": gridDensity]
            )
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
        
        // Add slider item
        let sliderItem = NSMenuItem()
        let slider = NSSlider(value: gridDensity, 
                            minValue: 20, 
                            maxValue: 100, 
                            target: self, 
                            action: #selector(sliderChanged(_:)))
        slider.frame = NSRect(x: 20, y: 0, width: 150, height: 20)
        sliderItem.view = slider
        menu.addItem(sliderItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func sliderChanged(_ sender: NSSlider) {
        gridDensity = sender.doubleValue
    }
}
