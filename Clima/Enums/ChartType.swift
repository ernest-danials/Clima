//
//  ChartType.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-25.
//

import Foundation

enum ChartType: String, CaseIterable, Identifiable {
    case top10CountriesByTerritorialMtCO2 = "Top 10 Countries by Territorial MtCO2"
    case territorialMtCO2ByRegion = "Territorial MtCO2 by Region"
    case top10CountriesByNDGainScore = "Top 10 Countries by ND Gain Score"
    case ndGainScoreByRegion = "ND Gain Score by Region"
    case top10CountriesByClimaJusticeScore = "Top 10 Countries by Clima Justice Score"
    case climaJusticeScoreByRegion = "Clima Justice Score by Region"

    case territorialMtCO2vsNDGainScore = "Territorial MtCO2 vs ND Gain Score"
    case territorialMtCO2vsClimaJusticeScore = "Territorial MtCO2 vs Clima Justice Score"
    case ndGainScorevsClimaJusticeScore = "ND Gain Score vs Clima Justice Score"

    case bubbleChart = "Climate Justice Bubble Chart"

    var id: Self { self }
    
    var imageName: String {
        switch self {
        case .top10CountriesByTerritorialMtCO2, .top10CountriesByNDGainScore, .top10CountriesByClimaJusticeScore:
            return "chart.bar.fill"
        case .territorialMtCO2ByRegion, .ndGainScoreByRegion, .climaJusticeScoreByRegion:
            return "chart.pie.fill"
        case .territorialMtCO2vsNDGainScore, .territorialMtCO2vsClimaJusticeScore, .ndGainScorevsClimaJusticeScore:
            return "chart.dots.scatter"
        case .bubbleChart:
            return "bubbles.and.sparkles.fill"
        }
    }
}
