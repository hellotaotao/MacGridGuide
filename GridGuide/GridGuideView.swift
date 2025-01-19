//  GridGuideView.swift
//  GridGuide
//
//  Created by Tao Wang on 14/2/2024.
//

import Foundation
import SwiftUI
import AppKit

struct GridGuideView: View {
    @State private var gridSize: CGFloat = 50
    @State private var numColumns: Int = 30
    @State private var numRows: Int = 30

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
        .onReceive(NotificationCenter.default.publisher(for: .gridDensityChanged)) { notification in
            if let value = notification.userInfo?["value"] as? Double {
                self.gridSize = CGFloat(value)
                self.numColumns = Int(ceil(NSScreen.main?.visibleFrame.width ?? 1440) / value)
                self.numRows = Int(ceil(NSScreen.main?.visibleFrame.height ?? 900) / value)
                print("Updated gridSize: \(gridSize), numColumns: \(numColumns), numRows: \(numRows)")
            }
        }
        .allowsHitTesting(false)
    }

    private func createCell(x: Int, y: Int) -> some View {
        let isEdge = x == 0 || y == 0 || x == numColumns - 1 || y == numRows - 1
        return Rectangle()
            .stroke(lineWidth: isEdge ? 1 : 1)
            .foregroundColor(isEdge ? .white.opacity(0.6) : .white.opacity(0.6))
    }
}