//
//  ShortcutManager.swift
//  GridGuide
//

import Combine
import Foundation

/// Keeps the system-wide hot keys in sync with the shortcuts stored in `GridSettings`.
final class ShortcutManager: ObservableObject {
    /// Actions whose shortcut could not be registered, usually because another app owns it.
    @Published private(set) var unavailableActions: Set<ShortcutAction> = []

    /// Set while the settings window records a shortcut, so the current hot keys reach the
    /// recorder instead of firing.
    var isPaused = false {
        didSet {
            guard isPaused != oldValue else { return }
            register(settings.shortcuts)
        }
    }

    private let settings: GridSettings
    private let handler: (ShortcutAction) -> Void
    private var hotKeys: [GlobalHotKey] = []
    private var cancellables = Set<AnyCancellable>()

    init(settings: GridSettings, handler: @escaping (ShortcutAction) -> Void) {
        self.settings = settings
        self.handler = handler

        // `$shortcuts` emits before the property changes, so register the emitted value.
        settings.$shortcuts
            .removeDuplicates()
            .sink { [weak self] in self?.register($0) }
            .store(in: &cancellables)
    }

    private func register(_ shortcuts: [ShortcutAction: Shortcut]) {
        // Release the old registrations first so an unchanged shortcut can be registered again.
        hotKeys.removeAll()
        guard !isPaused else { return }

        var unavailable = Set<ShortcutAction>()
        for action in ShortcutAction.allCases {
            guard let shortcut = shortcuts[action] else { continue }
            let hotKey = GlobalHotKey(keyCode: shortcut.keyCode, modifiers: shortcut.modifiers) { [weak self] in
                self?.handler(action)
            }
            if let hotKey {
                hotKeys.append(hotKey)
            } else {
                unavailable.insert(action)
            }
        }
        unavailableActions = unavailable
    }
}
