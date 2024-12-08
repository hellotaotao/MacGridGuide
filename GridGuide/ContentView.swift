//
//  ContentView.swift
//  GridGuide
//
//  Created by Tao Wang on 14/2/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GridGuide()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.2))
    }
}

#Preview {
    ContentView()
}
