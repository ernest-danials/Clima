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
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(countryDataManager)
        }
    }
}
