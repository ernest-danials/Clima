//
//  ClimaApp.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI

@main
struct ClimaApp: App {
    @StateObject var countryDataManager = CountryDataManager()
    @StateObject var onboardingPresentationManager = OnboardingPresentationManager()
    
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .onOpenURL { url in
                    print("Opened from:", url)
                }
                .environmentObject(countryDataManager)
                .environmentObject(onboardingPresentationManager)
        }
    }
}
