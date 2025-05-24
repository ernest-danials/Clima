//
//  ContentView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI

struct AppTabView: View {
    var body: some View {
        TabView {
            Tab(TabViewItem.home.rawValue, systemImage: TabViewItem.home.imageName) {
                HomeView()
            }
            
            Tab(TabViewItem.graphs.rawValue, systemImage: TabViewItem.graphs.imageName) {
                Text("Graphs")
            }
            
            Tab(TabViewItem.settings.rawValue, systemImage: TabViewItem.settings.imageName) {
                Text("Settings")
            }
        }
        .tabViewStyle(.tabBarOnly)
        .defaultAdaptableTabBarPlacement(.tabBar)
    }
}

#Preview {
    AppTabView()
        .environmentObject(CountryDataManager())
}
