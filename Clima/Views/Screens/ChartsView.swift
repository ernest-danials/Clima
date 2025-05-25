//
//  ChartsView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-24.
//

import SwiftUI
import Charts

struct ChartsView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager

    @State private var displayedCharts: [ChartType] = ChartType.allCases
    
    var body: some View {
        NavigationStack {
            ScrollView {
                displayedChartsView
                
                Divider().padding()

                ForEach(ChartType.allCases) { chart in
                    if displayedCharts.contains(chart) {
                        switch chart {
                        case .top10CountriesByTerritorialMtCO2:
                            top10CountriesByTerritorialMtCO2Chart
                        case .territorialMtCO2ByRegion:
                            Text(chart.rawValue)
                        case .top10CountriesByNDGainScore:
                            Text(chart.rawValue)
                        case .ndGainScoreByRegion:
                            Text(chart.rawValue)
                        case .top10CountriesByClimaJusticeScore:
                            Text(chart.rawValue)
                        case .climaJusticeScoreByRegion:
                            Text(chart.rawValue)
                        case .territorialMtCO2vsNDGainScore:
                            Text(chart.rawValue)
                        case .territorialMtCO2vsClimaJusticeScore:
                            Text(chart.rawValue)
                        case .ndGainScorevsClimaJusticeScore:
                            Text(chart.rawValue)
                        case .bubbleChart:
                            Text(chart.rawValue)
                        }
                    }
                }
            }
            .prioritiseScaleButtonStyle()
            .navigationTitle("Charts")
        }
    }
    
    private var displayedChartsView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(ChartType.allCases) { type in
                    let isDisplayed = (self.displayedCharts.contains(type))
                    
                    Button {
                        toggleDisplayStatus(for: type)
                        HapticManager.shared.impact(style: .soft)
                    } label: {
                        HStack {
                            Image(systemName: type.imageName)
                            
                            Text(type.rawValue)
                                .customFont(size: 18, weight: .medium)
                        }
                        .foregroundStyle(isDisplayed ? Color.white : .primary)
                        .padding()
                        .background {
                            if isDisplayed {
                                Capsule()
                                    .foregroundStyle(Color.accentColor)
                            } else {
                                Capsule()
                                    .fill(Material.ultraThin)
                            }
                        }
                    }.scaleButtonStyle()
                }
            }
        }
        .prioritiseScaleButtonStyle()
        .scrollIndicators(.hidden)
        .safeAreaPadding(.horizontal)
    }
    
    // MARK: Charts
    private var top10CountriesByTerritorialMtCO2Chart: some View {
        VStack(alignment: .leading) {
            Text(ChartType.top10CountriesByTerritorialMtCO2.rawValue)
                .customFont(size: 20, weight: .bold)
            
            Chart {
                ForEach(self.countryDataManager.countries.sorted(by: { $0.territorialMtCO2 > $1.territorialMtCO2 }).prefix(10)) { country in
                    BarMark(
                        x: .value("Territorial MtCO2", country.territorialMtCO2),
                        y: .value("Country", country.name)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(6)
                }
            }
            .frame(height: 600)
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel().font(.system(size: 18, weight: .medium))
                }
            }
            .chartXScale(domain: 0...12000)
        }
        .padding(25)
        .background(Material.ultraThin)
        .cornerRadius(20, corners: .allCorners)
        .padding(.horizontal)
        .transition(.blurReplace)
    }
    
    private func toggleDisplayStatus(for type: ChartType) {
        withAnimation {
            if self.displayedCharts.contains(type) {
                displayedCharts.removeAll(where: { $0 == type })
            } else {
                displayedCharts.append(type)
            }
        }
    }
}

#Preview {
    ChartsView()
        .environmentObject(CountryDataManager())
}
