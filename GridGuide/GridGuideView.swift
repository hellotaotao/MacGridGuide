//  GridGuideView.swift
//  GridGuide
//
//  Created by Tao Wang on 14/2/2024.
//

import Foundation
import SwiftUI
import AppKit

struct GridGuideView: View {
    @State private var gridSize: Int = 50
    let screenWidth = NSScreen.main?.visibleFrame.width ?? 1440
    let screenHeight = NSScreen.main?.visibleFrame.height ?? 900

    @State private var numColumns: Int = 30
    @State private var numRows: Int = 30
    @State private var transparency: Double = 0.5

    init() {
        _numColumns = State(initialValue: Int(screenWidth) / gridSize)
        _numRows = State(initialValue: Int(screenHeight) / gridSize)
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                ForEach(0..<numRows, id: \.self) { y in
                    HStack(spacing: 0) {
                        ForEach(0..<numColumns, id: \.self) { x in
                            createCell(x: x, y: y)
                        }
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gridSizeChanged)) { notification in
            if let value = notification.userInfo?["value"] as? Double {
                self.gridSize = Int(value)
                self.numColumns = Int(screenWidth / value)
                self.numRows = Int(screenHeight / value)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gridTransparencyChanged)) { notification in
            if let value = notification.userInfo?["value"] as? Double {
            self.transparency = value
            }
        }
        .opacity(transparency)
        .allowsHitTesting(false)
    }

    private func createCell(x: Int, y: Int) -> some View {
        let isEdge = x == 0 || y == 0 || x == numColumns - 1 || y == numRows - 1
        return Rectangle()
            .stroke(lineWidth: isEdge ? 1 : 1)
            .foregroundColor(isEdge ? .white.opacity(0.6) : .white.opacity(0.6))
    }
}
