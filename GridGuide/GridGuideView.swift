//  GridGuideView.swift
//  GridGuide
//
//  Created by Tao Wang on 14/2/2024.
//

import SwiftUI

enum GridGuideLayout {
    /// Grid line positions along one axis, starting at the origin and spaced by `cellSize`.
    static func linePositions(length: CGFloat, cellSize: CGFloat) -> [CGFloat] {
        guard length > 0 else { return [] }
        return Array(stride(from: 0, through: length, by: max(cellSize, 1)))
    }

    /// Keeps a line of `lineWidth` fully inside `0...limit` and snaps it to the device pixel grid
    /// so it renders crisply instead of being anti-aliased across two pixels.
    static func alignedPosition(_ position: CGFloat, limit: CGFloat, lineWidth: CGFloat, scale: CGFloat) -> CGFloat {
        let scale = max(scale, 1)
        let half = lineWidth / 2
        let clamped = min(max(position, half), max(limit - half, half))
        let widthInPixels = (lineWidth * scale).rounded()
        // Lines with an odd pixel width are centred on a pixel, even widths on a pixel boundary.
        let offset: CGFloat = widthInPixels.truncatingRemainder(dividingBy: 2) == 0 ? 0 : 0.5
        return ((clamped * scale - offset).rounded() + offset) / scale
    }
}

struct GridGuideView: View {
    @ObservedObject var settings: GridSettings
    @Environment(\.displayScale) private var displayScale

    private let lineWidth: CGFloat = 1

    var body: some View {
        let cellSize = CGFloat(settings.gridSize)
        let scale = displayScale

        Canvas { context, size in
            var path = Path()
            for x in GridGuideLayout.linePositions(length: size.width, cellSize: cellSize) {
                let x = GridGuideLayout.alignedPosition(x, limit: size.width, lineWidth: lineWidth, scale: scale)
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in GridGuideLayout.linePositions(length: size.height, cellSize: cellSize) {
                let y = GridGuideLayout.alignedPosition(y, limit: size.height, lineWidth: lineWidth, scale: scale)
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(path, with: .color(.white.opacity(0.6)), lineWidth: lineWidth)
        }
        .opacity(settings.opacity)
        .allowsHitTesting(false)
    }
}
