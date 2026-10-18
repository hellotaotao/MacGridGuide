//
//  GridSettings.swift
//  GridGuide
//

import Combine
import Foundation

/// Single source of truth for the overlay state, shared by the menu, the settings window and every
/// overlay panel.
final class GridSettings: ObservableObject {
    static let opacityRange: ClosedRange<Double> = 0.1...1.0

    private enum Key {
        static let presets = "presets"
        static let activePresetID = "activePresetID"
        static let style = "style"
        static let opacity = "opacity"
        static let shortcuts = "shortcuts"
        static let hasSeenWelcome = "hasSeenWelcome"
        /// Square grid size from 1.3 and earlier, migrated into the first built-in preset.
        static let legacyGridSize = "gridSize"
    }

    private let defaults: UserDefaults

    @Published var presets: [GridPreset] {
        didSet { save(presets, forKey: Key.presets) }
    }

    @Published var activePresetID: UUID {
        didSet { defaults.set(activePresetID.uuidString, forKey: Key.activePresetID) }
    }

    @Published var style: GridStyle {
        didSet { save(style, forKey: Key.style) }
    }

    @Published var opacity: Double {
        didSet { defaults.set(opacity, forKey: Key.opacity) }
    }

    /// Actions without an entry have no shortcut.
    @Published private(set) var shortcuts: [ShortcutAction: Shortcut] {
        didSet { save(shortcuts, forKey: Key.shortcuts) }
    }

    @Published var hasSeenWelcome: Bool {
        didSet { defaults.set(hasSeenWelcome, forKey: Key.hasSeenWelcome) }
    }

    /// Not persisted: the grid always shows on launch so a hidden grid never looks like a broken app.
    @Published var isVisible = true

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        var presets = Self.load([GridPreset].self, from: defaults, forKey: Key.presets) ?? []
        if presets.isEmpty {
            let legacySize = defaults.object(forKey: Key.legacyGridSize) == nil
                ? 60
                : Self.clamp(defaults.double(forKey: Key.legacyGridSize), to: SquareGrid.sizeRange)
            presets = GridPreset.builtIn(squareGridSize: legacySize)
        }
        self.presets = presets

        let storedID = defaults.string(forKey: Key.activePresetID).flatMap(UUID.init(uuidString:))
        activePresetID = presets.first { $0.id == storedID }?.id ?? presets[0].id

        style = Self.load(GridStyle.self, from: defaults, forKey: Key.style) ?? GridStyle()
        opacity = defaults.object(forKey: Key.opacity) == nil
            ? 0.5
            : Self.clamp(defaults.double(forKey: Key.opacity), to: Self.opacityRange)
        shortcuts = Self.load([ShortcutAction: Shortcut].self, from: defaults, forKey: Key.shortcuts)
            ?? Dictionary(uniqueKeysWithValues: ShortcutAction.allCases.map { ($0, $0.defaultShortcut) })
        hasSeenWelcome = defaults.bool(forKey: Key.hasSeenWelcome)
    }

    // MARK: Presets

    var activePreset: GridPreset {
        get { presets.first { $0.id == activePresetID } ?? presets[0] }
        set {
            guard let index = presets.firstIndex(where: { $0.id == newValue.id }) else { return }
            presets[index] = newValue
        }
    }

    var canDeletePreset: Bool { presets.count > 1 }

    func selectPreset(_ id: UUID) {
        guard presets.contains(where: { $0.id == id }) else { return }
        activePresetID = id
        isVisible = true
    }

    func selectNextPreset() {
        guard let index = presets.firstIndex(where: { $0.id == activePresetID }) else { return }
        selectPreset(presets[(index + 1) % presets.count].id)
    }

    func addPreset() {
        let preset = GridPreset.newLayout(named: uniqueName("New Layout"))
        presets.append(preset)
        selectPreset(preset.id)
    }

    func duplicateActivePreset() {
        var copy = activePreset
        copy.id = UUID()
        copy.name = uniqueName("\(copy.name) Copy")
        let index = presets.firstIndex { $0.id == activePresetID }.map { $0 + 1 } ?? presets.endIndex
        presets.insert(copy, at: index)
        selectPreset(copy.id)
    }

    func deleteActivePreset() {
        guard canDeletePreset, let index = presets.firstIndex(where: { $0.id == activePresetID }) else { return }
        presets.remove(at: index)
        selectPreset(presets[min(index, presets.count - 1)].id)
    }

    private func uniqueName(_ base: String) -> String {
        let names = Set(presets.map(\.name))
        guard names.contains(base) else { return base }
        var counter = 2
        while names.contains("\(base) \(counter)") {
            counter += 1
        }
        return "\(base) \(counter)"
    }

    // MARK: Shortcuts

    /// Assigning a shortcut that another action already uses moves it to `action`.
    func setShortcut(_ shortcut: Shortcut?, for action: ShortcutAction) {
        var updated = shortcuts
        if let shortcut {
            for (other, existing) in updated where other != action && existing == shortcut {
                updated[other] = nil
            }
        }
        updated[action] = shortcut
        shortcuts = updated
    }

    // MARK: Persistence

    private func save<Value: Encodable>(_ value: Value, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<Value: Decodable>(_ type: Value.Type, from defaults: UserDefaults, forKey key: String) -> Value? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static func clamp(_ value: Double, to range: ClosedRange<Double>) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
