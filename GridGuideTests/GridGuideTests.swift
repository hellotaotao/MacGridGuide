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

    func testGridLayoutCoversPartialCells() throws {
        let layout = GridGuideLayout(
            size: CGSize(width: 121, height: 119),
            gridSize: 60
        )

        XCTAssertEqual(layout.columns, 3)
        XCTAssertEqual(layout.rows, 2)
    }

    func testGridLayoutKeepsAtLeastOneCell() throws {
        let layout = GridGuideLayout(
            size: CGSize(width: 0, height: 0),
            gridSize: 60
        )

        XCTAssertEqual(layout.columns, 1)
        XCTAssertEqual(layout.rows, 1)
    }

    func testGridLayoutHandlesInvalidGridSize() throws {
        let layout = GridGuideLayout(
            size: CGSize(width: 3, height: 2),
            gridSize: 0
        )

        XCTAssertEqual(layout.columns, 3)
        XCTAssertEqual(layout.rows, 2)
    }

}
