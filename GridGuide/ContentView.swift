//
//  ContentView.swift
//  GridGuide
//
//  Created by Tao Wang on 14/2/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        GridGuideView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.clear)
            .ignoresSafeArea()
            .transaction { transaction in
                transaction.animation = nil
            }
    }
}

#Preview {
    ContentView()
}
