//  GridGuideView.swift
//  GridGuide
//
//  Created by Tao Wang on 14/2/2024.
//

import Foundation
import SwiftUI
import AppKit

struct GridGuideLayout: Equatable {
    let columns: Int
    let rows: Int

    init(size: CGSize, gridSize: Int) {
        let cellSize = max(CGFloat(gridSize), 1)
        columns = max(Int(ceil(size.width / cellSize)), 1)
        rows = max(Int(ceil(size.height / cellSize)), 1)
    }
}

struct GridGuideView: View {
    @State private var gridSize: Int = 60
    @State private var transparency: Double = 0.5
    @State private var isGridVisible: Bool = true

    var body: some View {
        GeometryReader { proxy in
            let layout = GridGuideLayout(size: proxy.size, gridSize: gridSize)

            VStack(spacing: 0) {
                ForEach(0..<layout.rows, id: \.self) { y in
                    HStack(spacing: 0) {
                        ForEach(0..<layout.columns, id: \.self) { x in
                            createCell(x: x, y: y, layout: layout)
                        }
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gridSizeChanged)) { notification in
            if let value = notification.userInfo?["value"] as? Double {
                self.gridSize = Int(value)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gridTransparencyChanged)) { notification in
            if let value = notification.userInfo?["value"] as? Double {
                self.transparency = value
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gridVisibilityChanged)) { notification in
            if let isVisible = notification.userInfo?["isVisible"] as? Bool {
                self.isGridVisible = isVisible
            }
        }
        .opacity(transparency)
        .opacity(isGridVisible ? 1 : 0)
        .allowsHitTesting(false)
    }

    private func createCell(x: Int, y: Int, layout: GridGuideLayout) -> some View {
        let isEdge = x == 0 || y == 0 || x == layout.columns - 1 || y == layout.rows - 1
        return Rectangle()
            .stroke(lineWidth: isEdge ? 1 : 1)
            .foregroundColor(isEdge ? .white.opacity(0.6) : .white.opacity(0.6))
    }
}
