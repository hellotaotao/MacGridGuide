//
//  GridGuideTests.swift
//  GridGuideTests
//
//  Created by Tao Wang on 14/2/2024.
//

import XCTest
import CoreGraphics
@testable import GridGuide

final class GridGuideTests: XCTestCase {

    func testLinePositionsStopAtPartialCell() throws {
        XCTAssertEqual(
            GridGuideLayout.linePositions(length: 121, cellSize: 60),
            [0, 60, 120]
        )
    }

    func testLinePositionsIncludeExactFarEdge() throws {
        XCTAssertEqual(
            GridGuideLayout.linePositions(length: 120, cellSize: 60),
            [0, 60, 120]
        )
    }

    func testLinePositionsAreEmptyForZeroLength() throws {
        XCTAssertEqual(GridGuideLayout.linePositions(length: 0, cellSize: 60), [])
    }

    func testLinePositionsHandleInvalidCellSize() throws {
        XCTAssertEqual(
            GridGuideLayout.linePositions(length: 3, cellSize: 0),
            [0, 1, 2, 3]
        )
    }

    func testAlignedPositionOnRetinaUsesPixelBoundaries() throws {
        // 1pt at 2x is two pixels wide, so the centre sits on a pixel boundary.
        XCTAssertEqual(GridGuideLayout.alignedPosition(60, limit: 200, lineWidth: 1, scale: 2), 60)
        XCTAssertEqual(GridGuideLayout.alignedPosition(60.3, limit: 200, lineWidth: 1, scale: 2), 60.5)
    }

    func testAlignedPositionOnNonRetinaUsesPixelCentres() throws {
        XCTAssertEqual(GridGuideLayout.alignedPosition(60, limit: 200, lineWidth: 1, scale: 1), 60.5)
    }

    func testAlignedPositionKeepsEdgeLinesOnScreen() throws {
        XCTAssertEqual(GridGuideLayout.alignedPosition(0, limit: 120, lineWidth: 1, scale: 2), 0.5)
        XCTAssertEqual(GridGuideLayout.alignedPosition(120, limit: 120, lineWidth: 1, scale: 2), 119.5)
        XCTAssertEqual(GridGuideLayout.alignedPosition(0, limit: 120, lineWidth: 1, scale: 1), 0.5)
        XCTAssertEqual(GridGuideLayout.alignedPosition(120, limit: 120, lineWidth: 1, scale: 1), 119.5)
    }

    func testColumnRectsCentreContainerWithMaxWidth() throws {
        let columns = ColumnGrid(isEnabled: true, count: 3, gutter: 10, margin: 20, maxWidth: 400)
        let rects = GridGuideLayout.columnRects(width: 1000, height: 50, columns: columns)
        // Container 400 centred at x = 300, inner width 360, column width (360 - 20) / 3.
        let columnWidth: CGFloat = 340 / 3
        XCTAssertEqual(rects.count, 3)
        XCTAssertEqual(rects[0].minX, 320, accuracy: 0.001)
        XCTAssertEqual(rects[0].width, columnWidth, accuracy: 0.001)
        XCTAssertEqual(rects[2].maxX, 680, accuracy: 0.001)
        XCTAssertEqual(rects[1].minX - rects[0].maxX, 10, accuracy: 0.001)
        XCTAssertEqual(rects[0].height, 50)
    }

    func testColumnRectsStretchWhenMaxWidthIsZero() throws {
        let columns = ColumnGrid(isEnabled: true, count: 2, gutter: 0, margin: 0, maxWidth: 0)
        let rects = GridGuideLayout.columnRects(width: 200, height: 10, columns: columns)
        XCTAssertEqual(rects, [CGRect(x: 0, y: 0, width: 100, height: 10), CGRect(x: 100, y: 0, width: 100, height: 10)])
    }

    func testColumnRectsAreEmptyWhenColumnsHaveNoRoom() throws {
        let columns = ColumnGrid(isEnabled: true, count: 12, gutter: 50, margin: 0, maxWidth: 0)
        XCTAssertEqual(GridGuideLayout.columnRects(width: 400, height: 10, columns: columns), [])
    }

    func testGuidePositions() throws {
        XCTAssertEqual(GridGuideLayout.guidePositions(length: 300, guides: Guides(showsCenter: true, showsThirds: false)), [150])
        XCTAssertEqual(GridGuideLayout.guidePositions(length: 300, guides: Guides(showsCenter: true, showsThirds: true)), [100, 150, 200])
        XCTAssertEqual(GridGuideLayout.guidePositions(length: 300, guides: Guides()), [])
    }

    func testSettingsPersistPresetsStyleAndOpacity() throws {
        let (defaults, cleanup) = try makeDefaults()
        defer { cleanup() }

        let settings = GridSettings(defaults: defaults)
        XCTAssertEqual(settings.presets.map(\.name), GridPreset.builtIn().map(\.name))
        XCTAssertEqual(settings.activePreset.grid.size, 60)
        XCTAssertEqual(settings.opacity, 0.5)

        settings.addPreset()
        settings.activePreset.columns.isEnabled = true
        settings.style.lineWidth = 2
        settings.opacity = 0.3

        let reloaded = GridSettings(defaults: defaults)
        XCTAssertEqual(reloaded.presets, settings.presets)
        XCTAssertEqual(reloaded.activePresetID, settings.activePresetID)
        XCTAssertTrue(reloaded.activePreset.columns.isEnabled)
        XCTAssertEqual(reloaded.style.lineWidth, 2)
        XCTAssertEqual(reloaded.opacity, 0.3)
    }

    func testSettingsMigrateLegacyGridSizeAndClampOpacity() throws {
        let (defaults, cleanup) = try makeDefaults()
        defer { cleanup() }
        defaults.set(80.0, forKey: "gridSize")
        defaults.set(5.0, forKey: "opacity")

        let settings = GridSettings(defaults: defaults)
        XCTAssertEqual(settings.presets[0].grid.size, 80)
        XCTAssertEqual(settings.activePresetID, settings.presets[0].id)
        XCTAssertEqual(settings.opacity, GridSettings.opacityRange.upperBound)
    }

    func testPresetCyclingDuplicationAndDeletion() throws {
        let (defaults, cleanup) = try makeDefaults()
        defer { cleanup() }
        let settings = GridSettings(defaults: defaults)
        let ids = settings.presets.map(\.id)

        settings.isVisible = false
        settings.selectNextPreset()
        XCTAssertEqual(settings.activePresetID, ids[1])
        XCTAssertTrue(settings.isVisible)

        settings.selectPreset(ids.last!)
        settings.selectNextPreset()
        XCTAssertEqual(settings.activePresetID, ids[0])

        settings.duplicateActivePreset()
        XCTAssertEqual(settings.presets[1].name, "Square Grid Copy")
        XCTAssertEqual(settings.activePresetID, settings.presets[1].id)
        settings.selectPreset(ids[0])
        settings.duplicateActivePreset()
        XCTAssertEqual(settings.activePreset.name, "Square Grid Copy 2")

        settings.deleteActivePreset()
        XCTAssertEqual(settings.presets.count, ids.count + 1)
        while settings.canDeletePreset {
            settings.deleteActivePreset()
        }
        settings.deleteActivePreset()
        XCTAssertEqual(settings.presets.count, 1)
    }

    func testAssigningUsedShortcutMovesIt() throws {
        let (defaults, cleanup) = try makeDefaults()
        defer { cleanup() }
        let settings = GridSettings(defaults: defaults)
        let toggle = ShortcutAction.toggleGrid.defaultShortcut

        settings.setShortcut(toggle, for: .nextPreset)
        XCTAssertNil(settings.shortcuts[.toggleGrid])
        XCTAssertEqual(settings.shortcuts[.nextPreset], toggle)

        settings.setShortcut(nil, for: .nextPreset)
        let reloaded = GridSettings(defaults: defaults)
        XCTAssertTrue(reloaded.shortcuts.isEmpty)
    }

    func testShortcutDisplayString() throws {
        XCTAssertEqual(ShortcutAction.toggleGrid.defaultShortcut.displayString, "⌃⌥⌘G")
        XCTAssertEqual(ShortcutAction.toggleGrid.defaultShortcut.menuKeyEquivalent, "g")
        XCTAssertEqual(Shortcut.keyName(keyCode: 49, characters: " "), "Space")
        XCTAssertNil(Shortcut.keyName(keyCode: 0, characters: "\u{1B}"))
    }

    private func makeDefaults() throws -> (UserDefaults, () -> Void) {
        let suiteName = "GridGuideTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        return (defaults, { defaults.removePersistentDomain(forName: suiteName) })
    }
}
