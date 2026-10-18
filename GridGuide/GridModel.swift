//
//  GridModel.swift
//  GridGuide
//

import AppKit
import Carbon.HIToolbox
import SwiftUI

/// A named overlay layout. Square grid, columns and guides can be combined freely,
/// like stacking layout grids on a Figma frame.
struct GridPreset: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var grid = SquareGrid()
    var columns = ColumnGrid()
    var guides = Guides()
}

struct SquareGrid: Codable, Equatable {
    static let sizeRange: ClosedRange<Double> = 4...400

    var isEnabled = false
    var size: Double = 60
    var axes: GridAxes = .both
}

enum GridAxes: String, Codable, CaseIterable, Identifiable {
    case both
    /// Horizontal lines only, i.e. a baseline grid.
    case horizontal
    case vertical

    var id: Self { self }

    var title: String {
        switch self {
        case .both: return "Both"
        case .horizontal: return "Rows"
        case .vertical: return "Columns"
        }
    }

    var drawsHorizontalLines: Bool { self != .vertical }
    var drawsVerticalLines: Bool { self != .horizontal }
}

struct ColumnGrid: Codable, Equatable {
    static let countRange: ClosedRange<Int> = 1...24
    static let gutterRange: ClosedRange<Double> = 0...200
    static let marginRange: ClosedRange<Double> = 0...400
    static let maxWidthRange: ClosedRange<Double> = 0...4000

    var isEnabled = false
    var count = 12
    var gutter: Double = 24
    /// Inset on both sides of the container, inside `maxWidth`.
    var margin: Double = 0
    /// Width of the centred container; 0 stretches the columns across the whole display.
    var maxWidth: Double = 0
}

struct Guides: Codable, Equatable {
    var showsCenter = false
    var showsThirds = false
}

/// Appearance shared by every preset.
struct GridStyle: Codable, Equatable {
    static let lineWidthRange: ClosedRange<Double> = 0.5...4

    var color = RGBAColor(red: 1, green: 0.23, blue: 0.19)
    var lineWidth: Double = 1
    /// Draws a contrasting edge around each line so it stays visible on light and dark content.
    var showsContrastOutline = false
}

struct RGBAColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double = 1

    init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(_ color: Color) {
        let nsColor = NSColor(color).usingColorSpace(.sRGB) ?? .white
        self.init(
            red: nsColor.redComponent,
            green: nsColor.greenComponent,
            blue: nsColor.blueComponent,
            alpha: nsColor.alphaComponent
        )
    }

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    /// Relative luminance per WCAG, used to pick an outline that contrasts with the line.
    var luminance: Double {
        func linear(_ component: Double) -> Double {
            component <= 0.03928 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
    }
}

extension GridPreset {
    static func builtIn(squareGridSize: Double = 60) -> [GridPreset] {
        [
            GridPreset(name: "Square Grid", grid: SquareGrid(isEnabled: true, size: squareGridSize)),
            GridPreset(name: "8pt Grid", grid: SquareGrid(isEnabled: true, size: 8)),
            GridPreset(
                name: "12 Columns",
                columns: ColumnGrid(isEnabled: true, count: 12, gutter: 24, margin: 0, maxWidth: 1200)
            ),
            GridPreset(name: "Rule of Thirds", guides: Guides(showsCenter: false, showsThirds: true)),
        ]
    }

    static func newLayout(named name: String) -> GridPreset {
        GridPreset(name: name, grid: SquareGrid(isEnabled: true))
    }
}

// MARK: - Shortcuts

enum ShortcutAction: String, Codable, CaseIterable, Identifiable {
    case toggleGrid
    case nextPreset

    var id: Self { self }

    var title: String {
        switch self {
        case .toggleGrid: return "Show or hide grid"
        case .nextPreset: return "Switch to next layout"
        }
    }

    var defaultShortcut: Shortcut {
        let modifiers = UInt32(controlKey | optionKey | cmdKey)
        switch self {
        // Control-Option-Command avoids clashing with shortcuts like Find Next (Command-G).
        case .toggleGrid: return Shortcut(keyCode: UInt32(kVK_ANSI_G), modifiers: modifiers, key: "G")
        case .nextPreset: return Shortcut(keyCode: UInt32(kVK_ANSI_N), modifiers: modifiers, key: "N")
        }
    }
}

/// A global keyboard shortcut stored as a Carbon key code and modifier mask.
struct Shortcut: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32
    /// Human-readable key name captured when the shortcut was recorded.
    var key: String

    var displayString: String {
        var result = ""
        if modifiers & UInt32(controlKey) != 0 { result += "⌃" }
        if modifiers & UInt32(optionKey) != 0 { result += "⌥" }
        if modifiers & UInt32(shiftKey) != 0 { result += "⇧" }
        if modifiers & UInt32(cmdKey) != 0 { result += "⌘" }
        return result + key
    }

    /// Key equivalent for an `NSMenuItem`; empty for keys a menu item cannot display as a character.
    var menuKeyEquivalent: String {
        key.count == 1 ? key.lowercased() : ""
    }

    var menuModifierMask: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        if modifiers & UInt32(controlKey) != 0 { flags.insert(.control) }
        if modifiers & UInt32(optionKey) != 0 { flags.insert(.option) }
        if modifiers & UInt32(shiftKey) != 0 { flags.insert(.shift) }
        if modifiers & UInt32(cmdKey) != 0 { flags.insert(.command) }
        return flags
    }

    /// Returns nil unless the event carries Command, Control or Option, so plain typing never
    /// becomes a system-wide shortcut.
    init?(event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard !flags.intersection([.command, .control, .option]).isEmpty else { return nil }
        guard let key = Self.keyName(keyCode: Int(event.keyCode), characters: event.charactersIgnoringModifiers) else {
            return nil
        }

        var modifiers: UInt32 = 0
        if flags.contains(.control) { modifiers |= UInt32(controlKey) }
        if flags.contains(.option) { modifiers |= UInt32(optionKey) }
        if flags.contains(.shift) { modifiers |= UInt32(shiftKey) }
        if flags.contains(.command) { modifiers |= UInt32(cmdKey) }
        self.init(keyCode: UInt32(event.keyCode), modifiers: modifiers, key: key)
    }

    init(keyCode: UInt32, modifiers: UInt32, key: String) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.key = key
    }

    static func keyName(keyCode: Int, characters: String?) -> String? {
        let specialKeys: [Int: String] = [
            kVK_Space: "Space", kVK_Return: "↩", kVK_Tab: "⇥",
            kVK_LeftArrow: "←", kVK_RightArrow: "→", kVK_UpArrow: "↑", kVK_DownArrow: "↓",
            kVK_F1: "F1", kVK_F2: "F2", kVK_F3: "F3", kVK_F4: "F4", kVK_F5: "F5", kVK_F6: "F6",
            kVK_F7: "F7", kVK_F8: "F8", kVK_F9: "F9", kVK_F10: "F10", kVK_F11: "F11", kVK_F12: "F12",
        ]
        if let name = specialKeys[keyCode] {
            return name
        }
        guard let characters, let scalar = characters.unicodeScalars.first,
              characters.unicodeScalars.count == 1,
              !CharacterSet.controlCharacters.contains(scalar),
              // Function-key private use area (arrows, Home, Page Up, ...)
              !(0xF700...0xF8FF).contains(scalar.value)
        else { return nil }
        return characters.uppercased()
    }
}
