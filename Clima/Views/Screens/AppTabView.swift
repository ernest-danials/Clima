//
//  ContentView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI

struct AppTabView: View {
    @EnvironmentObject var onboardingPresentationManager: OnboardingPresentationManager
    var body: some View {
        TabView {
            Tab(TabViewItem.map.rawValue, systemImage: TabViewItem.map.imageName) {
                MapView()
            }
            
            Tab(TabViewItem.charts.rawValue, systemImage: TabViewItem.charts.imageName) {
                ChartsView()
            }
            
            Tab(TabViewItem.compare.rawValue, systemImage: TabViewItem.compare.imageName) {
                CompareView()
            }
            
            Tab(TabViewItem.resources.rawValue, systemImage: TabViewItem.resources.imageName) {
                ResourcesView()
            }
        }
        .tabViewStyle(.tabBarOnly)
        .defaultAdaptableTabBarPlacement(.tabBar)
        .task { onboardingPresentationManager.showOnboardingIfNecessary() }
        .overlay {
            if self.onboardingPresentationManager.isShowingOnboarding {
                OnboardingView()
            }
        }
    }
}

#Preview {
    AppTabView()
        .environmentObject(CountryDataManager())
}
