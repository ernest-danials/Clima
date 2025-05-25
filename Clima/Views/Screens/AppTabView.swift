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
            Tab(TabViewItem.map.rawValue, systemImage: TabViewItem.map.imageName) {
                MapView()
            }
            
            Tab(TabViewItem.charts.rawValue, systemImage: TabViewItem.charts.imageName) {
                ChartsView()
            }
            
            Tab(TabViewItem.compare.rawValue, systemImage: TabViewItem.compare.imageName) {
                Text("Compare")
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
