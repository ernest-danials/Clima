//
//  ChartType.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-25.
//

import Foundation

enum ChartType: String, CaseIterable, Identifiable {
    case top10CountriesByTerritorialMtCO2 = "Top 10 Countries by Territorial MtCO2"
    case top10CountriesByNDGainScore = "Top 10 Countries by ND Gain Score"
    case top10CountriesByClimaJusticeScore = "Top 10 Countries by Clima Justice Score"
    
    case territorialMtCO2ByRegion = "Territorial MtCO2 by Region"
    case ndGainScoreByRegion = "ND Gain Score by Region"
    case climaJusticeScoreByRegion = "Clima Justice Score by Region"

    case territorialMtCO2vsNDGainScore = "Territorial MtCO2 vs ND Gain Score"
    case territorialMtCO2vsClimaJusticeScore = "Territorial MtCO2 vs Clima Justice Score"
    case ndGainScorevsClimaJusticeScore = "ND Gain Score vs Clima Justice Score"

    var id: Self { self }
    
    static let top10Charts: [Self] = [.top10CountriesByTerritorialMtCO2, .top10CountriesByNDGainScore, .top10CountriesByClimaJusticeScore]
    static let regionalCharts: [Self] = [.territorialMtCO2ByRegion, .ndGainScoreByRegion, .climaJusticeScoreByRegion]
    static let comparativeCharts: [Self] = [.territorialMtCO2vsNDGainScore, .territorialMtCO2vsClimaJusticeScore, .ndGainScorevsClimaJusticeScore]
        
    
    var imageName: String {
        switch self {
        case .top10CountriesByTerritorialMtCO2, .top10CountriesByNDGainScore, .top10CountriesByClimaJusticeScore:
            return "chart.bar.yaxis"
        case .territorialMtCO2ByRegion, .ndGainScoreByRegion, .climaJusticeScoreByRegion:
            return "chart.pie.fill"
        case .territorialMtCO2vsNDGainScore, .territorialMtCO2vsClimaJusticeScore, .ndGainScorevsClimaJusticeScore:
            return "chart.dots.scatter"
        }
    }
    
    var description: String {
        switch self {
        case .top10CountriesByTerritorialMtCO2:
            return "This horizontal bar chart displays the ten countries with the highest territorial CO2 emissions measured in megatonnes (MtCO2). Each bar is colour-coded by geographical region and shows the exact emission values. This chart identifies the world's largest carbon emitters and reveals which regions contribute most to global greenhouse gas emissions, highlighting countries with the greatest responsibility for climate change mitigation."
            
        case .top10CountriesByNDGainScore:
            return "This horizontal bar chart shows the ten countries with the highest Notre Dame Global Adaptation Initiative (ND-GAIN) scores. The ND-GAIN score measures a country's vulnerability to climate change and its readiness to improve resilience. Higher scores indicate lower vulnerability and greater adaptive capacity. This chart identifies which countries are best positioned to handle climate impacts and adapt to changing conditions."
            
        case .top10CountriesByClimaJusticeScore:
            return "This horizontal bar chart presents the ten countries with the highest Clima Justice scores, a composite metric that balances climate vulnerability with emission responsibility. Countries with higher scores typically have low emissions but high adaptive capacity, representing nations that contribute least to climate change whilst being well-prepared for its impacts. This highlights climate justice by showing countries that are climate leaders rather than climate burdens."
            
        case .territorialMtCO2ByRegion:
            return "This doughnut chart illustrates the total territorial CO2 emissions aggregated by geographical region. Each sector represents the cumulative emissions from all countries within that region, showing the relative contribution of different parts of the world to global carbon emissions. This visualisation reveals regional patterns in climate impact and helps identify which areas of the world bear the greatest responsibility for greenhouse gas emissions."
            
        case .ndGainScoreByRegion:
            return "This doughnut chart displays the total ND-GAIN scores aggregated by geographical region. By summing the adaptive capacity and vulnerability scores of countries within each region, this chart shows which parts of the world are collectively best prepared for climate change impacts. Larger sectors indicate regions with higher overall climate resilience and adaptive capacity."
            
        case .climaJusticeScoreByRegion:
            return "This doughnut chart shows the total Clima Justice scores aggregated by geographical region. By combining low emissions with high adaptive capacity, this metric highlights regions that contribute positively to global climate justice. Larger sectors represent regions that collectively have low climate impact whilst maintaining strong resilience, demonstrating responsible climate stewardship."
            
        case .territorialMtCO2vsNDGainScore:
            return "This scatter plot compares territorial CO2 emissions against ND-GAIN scores for all countries, with each point coloured by region. The chart reveals the relationship between a country's carbon footprint and its climate resilience. Countries in the upper-left quadrant (low emissions, high ND-GAIN) represent climate justice ideals, whilst those in the lower-right (high emissions, low ND-GAIN) face the greatest climate challenges. Extreme outliers are omitted for visual clarity."
            
        case .territorialMtCO2vsClimaJusticeScore:
            return "This scatter plot examines the relationship between territorial CO2 emissions and Clima Justice scores across all countries. Each point represents a country, coloured by region. The chart illustrates how emission levels correlate with climate justice performance. Countries with high Clima Justice scores and low emissions demonstrate responsible climate leadership, whilst those with high emissions and low scores represent areas needing urgent climate action. Extreme outliers are excluded for better visualisation."
            
        case .ndGainScorevsClimaJusticeScore:
            return "This scatter plot compares ND-GAIN scores with Clima Justice scores for all countries, revealing how climate vulnerability and adaptive capacity relate to overall climate justice performance. Countries in the upper-right quadrant excel in both metrics, demonstrating strong climate resilience and responsible emission practices. This chart helps identify nations that serve as models for sustainable climate policy and those requiring support for climate adaptation."
        }
    }
}
