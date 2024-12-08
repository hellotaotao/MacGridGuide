//
//  GridGuideApp.swift
//  GridGuide
//
//  Created by Tao Wang on 14/2/2024.
//

import SwiftUI
import AppKit

@main
struct GridGuideApp: App {
    init() {
        DispatchQueue.main.async {
            NSApp.windows.forEach { window in
                window.backgroundColor = .clear
                window.isOpaque = false
                window.level = .floating
                window.ignoresMouseEvents = true
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1000, height: 800)
        .defaultPosition(.center)
    }
}
