//
//  ContentView.swift
//  NATO-1
//
//  Created by Leslie Chicoine on 4/1/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            LearnHomeView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(0)

            DrillHomeView()
                .tabItem {
                    Label("Drill", systemImage: "bolt.fill")
                }
                .tag(1)

            CodebookView()
                .tabItem {
                    Label("Codebook", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
