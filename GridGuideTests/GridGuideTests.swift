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

    func testSettingsPersistAndClampStoredValues() throws {
        let suiteName = "GridGuideTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = GridSettings(defaults: defaults)
        XCTAssertEqual(settings.gridSize, 60)
        XCTAssertEqual(settings.opacity, 0.5)

        settings.gridSize = 80
        settings.opacity = 0.3
        let reloaded = GridSettings(defaults: defaults)
        XCTAssertEqual(reloaded.gridSize, 80)
        XCTAssertEqual(reloaded.opacity, 0.3)

        defaults.set(500.0, forKey: "gridSize")
        XCTAssertEqual(GridSettings(defaults: defaults).gridSize, GridSettings.gridSizeRange.upperBound)
    }

}
