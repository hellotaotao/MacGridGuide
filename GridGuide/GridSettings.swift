//
//  GridSettings.swift
//  GridGuide
//

import Combine
import Foundation

/// Single source of truth for the overlay state, shared by the menu and every overlay panel.
final class GridSettings: ObservableObject {
    static let gridSizeRange: ClosedRange<Double> = 40...100
    static let opacityRange: ClosedRange<Double> = 0.1...1.0

    private enum Key {
        static let gridSize = "gridSize"
        static let opacity = "opacity"
    }

    private let defaults: UserDefaults

    @Published var gridSize: Double {
        didSet { defaults.set(gridSize, forKey: Key.gridSize) }
    }

    @Published var opacity: Double {
        didSet { defaults.set(opacity, forKey: Key.opacity) }
    }

    /// Not persisted: the grid always shows on launch so a hidden grid never looks like a broken app.
    @Published var isVisible = true

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        gridSize = Self.storedValue(in: defaults, forKey: Key.gridSize, fallback: 60, range: Self.gridSizeRange)
        opacity = Self.storedValue(in: defaults, forKey: Key.opacity, fallback: 0.5, range: Self.opacityRange)
    }

    private static func storedValue(
        in defaults: UserDefaults,
        forKey key: String,
        fallback: Double,
        range: ClosedRange<Double>
    ) -> Double {
        guard defaults.object(forKey: key) != nil else { return fallback }
        return min(max(defaults.double(forKey: key), range.lowerBound), range.upperBound)
    }
}
