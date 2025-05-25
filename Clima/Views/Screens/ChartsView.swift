//
//  ChartsView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-24.
//

import SwiftUI

struct ChartsView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager

    enum ChartType: String, CaseIterable, Identifiable {
        case top20CountriesByTerritorialMtCO2 = "Top 20 Countries by Territorial MtCO2"
        case territorialMtCO2ByRegion = "Territorial MtCO2 by Region"
        case top20CountriesByNDGainScore = "Top 20 Countries by ND Gain Score"
        case ndGainScoreByRegion = "ND Gain Score by Region"
        case top20CountriesByClimaJusticeScore = "Top 20 Countries by Clima Justice Score"
        case climaJusticeScoreByRegion = "Clima Justice Score by Region"

        case territorialMtCO2vsNDGainScore = "Territorial MtCO2 vs ND Gain Score"
        case territorialMtCO2vsClimaJusticeScore = "Territorial MtCO2 vs Clima Justice Score"
        case ndGainScorevsClimaJusticeScore = "ND Gain Score vs Clima Justice Score"

        case bubbleChart = "Climate Justice Bubble Chart"

        var id: Self { self }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                
            }
            .prioritiseScaleButtonStyle()
            .navigationTitle("Charts")
        }
    }
}

#Preview {
    ChartsView()
        .environmentObject(CountryDataManager())
}
