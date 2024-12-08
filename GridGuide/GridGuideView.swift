//  GridGuideView.swift
//  GridGuide
//
//  Created by Tao Wang on 14/2/2024.
//

import Foundation
import SwiftUI

struct GridGuide: View {
    let gridSize: CGFloat = 10
    let numColumns: Int = 10
    let numRows: Int = 10
    
    private func createCell(x: Int, y: Int) -> some View {
        let isEdge = x == 0 || y == 0 || x == numColumns - 1 || y == numRows - 1
        return Rectangle()
            .stroke(lineWidth: isEdge ? 2 : 1)
            .foregroundColor(isEdge ? .primary : .secondary)
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
    }
}
