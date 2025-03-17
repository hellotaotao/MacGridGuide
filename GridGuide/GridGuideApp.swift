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
    @objc dynamic var gridSize: Double = 60 {
        didSet {        
            NotificationCenter.default.post(
                name: NSNotification.Name("gridSizeChanged"), 
                object: nil,
                userInfo: ["value": gridSize]
            )
            valueLabel?.stringValue = "\(Int(gridSize))"
        }
    }
    
    @objc dynamic var transparency: Double = 0.5 {
        didSet {
            NotificationCenter.default.post(
                name: NSNotification.Name("gridTransparencyChanged"),
                object: nil,
                userInfo: ["value": transparency]
            )
            transparencyLabel?.stringValue = String(format: "%.2f", transparency)
        }
    }
    
    @objc dynamic var isGridVisible: Bool = true {
        didSet {
            NotificationCenter.default.post(
                name: NSNotification.Name("gridVisibilityChanged"),
                object: nil,
                userInfo: ["isVisible": isGridVisible]
            )
        }
    }
    
    private var transparencyLabel: NSTextField!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.setupStatusItem()
            self?.registerGlobalShortcut()
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
        
        // Add transparency slider
        let transparencyMenuItem = NSMenuItem()
        let transparencyContainerView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 40))
        
        let transparencySlider = NSSlider(value: transparency, 
                                          minValue: 0.1, 
                                          maxValue: 1.0, 
                                          target: self, 
                                          action: #selector(transparencySliderChanged(_:)))
        transparencySlider.frame = NSRect(x: 20, y: 10, width: 130, height: 20)
        
        transparencyLabel = NSTextField(frame: NSRect(x: 160, y: 10, width: 30, height: 20))
        transparencyLabel.isEditable = false
        transparencyLabel.isBordered = false
        transparencyLabel.backgroundColor = .clear
        transparencyLabel.stringValue = String(format: "%.2f", transparency)
        
        transparencyContainerView.addSubview(transparencySlider)
        transparencyContainerView.addSubview(transparencyLabel)
        
        transparencyMenuItem.view = transparencyContainerView
        menu.addItem(transparencyMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    private func registerGlobalShortcut() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        print("Accessibility permission status: \(accessEnabled)")
        
        if !accessEnabled {
            print("Please grant Accessibility permission in System Settings.")
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
        
        print("Registering global shortcut for Command+G")
        
        // Add local monitor
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "g" {
                print("Command+G detected in local monitor!")
                self?.toggleGridVisibility()
                return nil // Consume the event
            }
            return event
        }
        
        // Keep global monitor
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "g" {
                print("Command+G detected in global monitor!")
                self?.toggleGridVisibility()
            }
        }
    }
    
    private func toggleGridVisibility() {
        isGridVisible.toggle()
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func sliderChanged(_ sender: NSSlider) {
        gridSize = round(sender.doubleValue)
    }
    
    @objc func transparencySliderChanged(_ sender: NSSlider) {
        transparency = sender.doubleValue
    }
}
