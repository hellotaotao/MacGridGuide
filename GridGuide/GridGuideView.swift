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

    /// Column bands for a container of `maxWidth` (or the full width) centred in `width`,
    /// inset by `margin` on both sides. Empty when the columns would have no width.
    static func columnRects(width: CGFloat, height: CGFloat, columns: ColumnGrid) -> [CGRect] {
        guard columns.count > 0, width > 0, height > 0 else { return [] }
        let containerWidth = columns.maxWidth > 0 ? min(CGFloat(columns.maxWidth), width) : width
        let innerWidth = containerWidth - 2 * CGFloat(columns.margin)
        let gutter = CGFloat(columns.gutter)
        let count = CGFloat(columns.count)
        let columnWidth = (innerWidth - gutter * (count - 1)) / count
        guard columnWidth > 0 else { return [] }

        let originX = (width - containerWidth) / 2 + CGFloat(columns.margin)
        return (0..<columns.count).map { index in
            CGRect(x: originX + CGFloat(index) * (columnWidth + gutter), y: 0, width: columnWidth, height: height)
        }
    }

    /// Centre and rule-of-thirds positions along one axis.
    static func guidePositions(length: CGFloat, guides: Guides) -> [CGFloat] {
        guard length > 0 else { return [] }
        var positions: [CGFloat] = []
        if guides.showsThirds { positions.append(length / 3) }
        if guides.showsCenter { positions.append(length / 2) }
        if guides.showsThirds { positions.append(length * 2 / 3) }
        return positions
    }

    /// Snaps a rectangle's edges to device pixels so column bands have crisp borders.
    static func pixelAligned(_ rect: CGRect, scale: CGFloat) -> CGRect {
        let scale = max(scale, 1)
        let minX = (rect.minX * scale).rounded() / scale
        let maxX = (rect.maxX * scale).rounded() / scale
        return CGRect(x: minX, y: rect.minY, width: max(maxX - minX, 1 / scale), height: rect.height)
    }
}

struct GridGuideView: View {
    @ObservedObject var settings: GridSettings
    @Environment(\.displayScale) private var displayScale

    private static let columnFillOpacity = 0.2
    private static let guideDash: [CGFloat] = [6, 4]

    var body: some View {
        let preset = settings.activePreset
        let style = settings.style
        let scale = displayScale

        Canvas { context, size in
            let lineWidth = CGFloat(style.lineWidth)
            let color = style.color.color

            if preset.columns.isEnabled {
                for rect in GridGuideLayout.columnRects(width: size.width, height: size.height, columns: preset.columns) {
                    context.fill(
                        Path(GridGuideLayout.pixelAligned(rect, scale: scale)),
                        with: .color(color.opacity(Self.columnFillOpacity))
                    )
                }
            }

            let gridPath = preset.grid.isEnabled
                ? Self.gridPath(size: size, grid: preset.grid, lineWidth: lineWidth, scale: scale)
                : Path()
            let guidePath = Self.guidePath(size: size, guides: preset.guides, lineWidth: lineWidth, scale: scale)
            let guideStroke = StrokeStyle(lineWidth: lineWidth, dash: Self.guideDash)

            if style.showsContrastOutline {
                // A light line gets a dark edge and vice versa.
                let outline: Color = style.color.luminance > 0.4 ? .black.opacity(0.6) : .white.opacity(0.7)
                let outlineWidth = lineWidth + 2
                context.stroke(gridPath, with: .color(outline), lineWidth: outlineWidth)
                context.stroke(guidePath, with: .color(outline), style: StrokeStyle(lineWidth: outlineWidth, dash: Self.guideDash))
            }
            context.stroke(gridPath, with: .color(color), lineWidth: lineWidth)
            context.stroke(guidePath, with: .color(color), style: guideStroke)
        }
        .opacity(settings.opacity)
        .allowsHitTesting(false)
    }

    private static func gridPath(size: CGSize, grid: SquareGrid, lineWidth: CGFloat, scale: CGFloat) -> Path {
        let cellSize = CGFloat(max(grid.size, SquareGrid.sizeRange.lowerBound))
        var path = Path()
        if grid.axes.drawsVerticalLines {
            for x in GridGuideLayout.linePositions(length: size.width, cellSize: cellSize) {
                addVerticalLine(to: &path, x: x, size: size, lineWidth: lineWidth, scale: scale)
            }
        }
        if grid.axes.drawsHorizontalLines {
            for y in GridGuideLayout.linePositions(length: size.height, cellSize: cellSize) {
                addHorizontalLine(to: &path, y: y, size: size, lineWidth: lineWidth, scale: scale)
            }
        }
        return path
    }

    private static func guidePath(size: CGSize, guides: Guides, lineWidth: CGFloat, scale: CGFloat) -> Path {
        var path = Path()
        for x in GridGuideLayout.guidePositions(length: size.width, guides: guides) {
            addVerticalLine(to: &path, x: x, size: size, lineWidth: lineWidth, scale: scale)
        }
        for y in GridGuideLayout.guidePositions(length: size.height, guides: guides) {
            addHorizontalLine(to: &path, y: y, size: size, lineWidth: lineWidth, scale: scale)
        }
        return path
    }

    private static func addVerticalLine(to path: inout Path, x: CGFloat, size: CGSize, lineWidth: CGFloat, scale: CGFloat) {
        let x = GridGuideLayout.alignedPosition(x, limit: size.width, lineWidth: lineWidth, scale: scale)
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: size.height))
    }

    private static func addHorizontalLine(to path: inout Path, y: CGFloat, size: CGSize, lineWidth: CGFloat, scale: CGFloat) {
        let y = GridGuideLayout.alignedPosition(y, limit: size.height, lineWidth: lineWidth, scale: scale)
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: size.width, y: y))
    }
}
