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
    @State private var isShowingTopDisclaimer: Bool = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                displayedChartsList
                
                if self.isShowingTopDisclaimer {
                    HStack {
                        Label("Clima uses data from 2022.", systemImage: "info.circle")
                        
                        Spacer()
                        
                        Button {
                            withAnimation { self.isShowingTopDisclaimer = false }
                            HapticManager.shared.impact(style: .soft)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                        }.scaleButtonStyle(scaleAmount: 0.96)
                    }
                    .padding()
                    .background(Material.ultraThin)
                    .cornerRadius(13, corners: .allCorners)
                    .padding([.horizontal, .top])
                    .transition(.blurReplace)
                }
                
                LazyVStack(spacing: 20) {
                    if self.displayedCharts.isEmpty {
                        ContentUnavailableView("No Charts Selected", systemImage: "chart.pie.fill", description: Text("There are no charts selected to display."))
                    }
                    
                    LazyVStack(spacing: 15) {
                        ForEach(ChartType.top10Charts) { chart in
                            if displayedCharts.contains(chart) {
                                getChartView(for: chart)
                            }
                        }
                    }
                    
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 15) {
                        ForEach(ChartType.regionalCharts) { chart in
                            if displayedCharts.contains(chart) {
                                getChartView(for: chart)
                                    .alignViewVertically(to: .top)
                            }
                        }
                    }
                    
                    LazyVStack(spacing: 15) {
                        ForEach(ChartType.comparativeCharts) { chart in
                            if displayedCharts.contains(chart) {
                                getChartView(for: chart)
                            }
                        }
                    }
                }.padding(.top)
            }
            .prioritiseScaleButtonStyle()
            .navigationTitle("Charts")
        }
    }
    
    private var displayedChartsList: some View {
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
                    }
                    .scaleButtonStyle()
                }
            }.scrollTargetLayout()
        }
        .prioritiseScaleButtonStyle()
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .safeAreaPadding(.horizontal)
    }
    
    // MARK: Top 10 Charts
    private var top10CountriesByTerritorialMtCO2Chart: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ChartType.top10CountriesByTerritorialMtCO2.rawValue)
                .customFont(size: 20, weight: .bold)
            
            Text(ChartType.top10CountriesByTerritorialMtCO2.description)
                .customFont(size: 18)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            Chart {
                ForEach(self.countryDataManager.countries.sorted(by: { $0.territorialMtCO2 > $1.territorialMtCO2 }).prefix(10)) { country in
                    BarMark(
                        x: .value("Territorial MtCO2", country.territorialMtCO2),
                        y: .value("Country", country.name)
                    )
                    .foregroundStyle(by: .value("Region", country.getRegion().rawValue))
                    .cornerRadius(6)
                    .annotation(position: .trailing) {
                        Text(String(format: "%.1f", country.territorialMtCO2))
                            .minimumScaleFactor(0.3)
                    }
                }
            }
            .frame(height: 700)
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel().font(.system(size: 18, weight: .medium))
                }
            }
            .chartXScale(domain: 0...12500)
        }.chartBackgroundStyle()
    }
    
    private var top10CountriesByNDGainScoreChart: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ChartType.top10CountriesByNDGainScore.rawValue)
                .customFont(size: 20, weight: .bold)
            
            Text(ChartType.top10CountriesByNDGainScore.description)
                .customFont(size: 18)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            Chart {
                ForEach(self.countryDataManager.countries.sorted(by: { $0.NDGainScore > $1.NDGainScore }).prefix(10)) { country in
                    BarMark(
                        x: .value("ND-Gain Score", country.NDGainScore),
                        y: .value("Country", country.name)
                    )
                    .foregroundStyle(by: .value("Region", country.getRegion().rawValue))
                    .cornerRadius(6)
                    .annotation(position: .trailing) {
                        Text(String(format: "%.1f", country.NDGainScore))
                            .minimumScaleFactor(0.3)
                    }
                }
            }
            .frame(height: 700)
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel().font(.system(size: 18, weight: .medium))
                }
            }
        }.chartBackgroundStyle()
    }
    
    private var top10CountriesByClimaJusticeScoreChart: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ChartType.top10CountriesByClimaJusticeScore.rawValue)
                .customFont(size: 20, weight: .bold)
            
            Text(ChartType.top10CountriesByClimaJusticeScore.description)
                .customFont(size: 18)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            Chart {
                let (minLog, rangeLog) = self.countryDataManager.countries.logCO2Scaling()
                
                ForEach(self.countryDataManager.countries.sorted(by: { $0.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog) > $1.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog) }).prefix(10)) { country in
                    BarMark(
                        x: .value("Clima Justice Score", country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)),
                        y: .value("Country", country.name)
                    )
                    .foregroundStyle(by: .value("Region", country.getRegion().rawValue))
                    .cornerRadius(6)
                    .annotation(position: .trailing) {
                        Text(String(format: "%.1f", country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)))
                            .minimumScaleFactor(0.3)
                    }
                }
            }
            .frame(height: 700)
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel().font(.system(size: 18, weight: .medium))
                }
            }
        }.chartBackgroundStyle()
    }
    
    private var bottom10CountriesByClimaJusticeScoreChart: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ChartType.bottom10CountriesByClimaJusticeScore.rawValue)
                .customFont(size: 20, weight: .bold)
            
            Text(ChartType.bottom10CountriesByClimaJusticeScore.description)
                .customFont(size: 18)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            Chart {
                let (minLog, rangeLog) = self.countryDataManager.countries.logCO2Scaling()
                
                ForEach(self.countryDataManager.countries.sorted(by: { $0.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog) < $1.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog) }).prefix(10)) { country in
                    BarMark(
                        x: .value("Clima Justice Score", country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)),
                        y: .value("Country", country.name)
                    )
                    .foregroundStyle(by: .value("Region", country.getRegion().rawValue))
                    .cornerRadius(6)
                    .annotation(position: .trailing) {
                        Text(String(format: "%.1f", country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)))
                            .minimumScaleFactor(0.3)
                    }
                }
            }
            .frame(height: 700)
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel().font(.system(size: 18, weight: .medium))
                }
            }
            .chartXScale(domain: 0...45)
        }.chartBackgroundStyle()
    }
    
    // MARK: Regional Charts
    private var territorialMtCO2ByRegionChart: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ChartType.territorialMtCO2ByRegion.rawValue)
                .customFont(size: 20, weight: .bold)
            
            Text(ChartType.territorialMtCO2ByRegion.description)
                .customFont(size: 18)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            Chart {
                ForEach(Region.allCases) { region in
                    let countries = countryDataManager.countries.filter { $0.getRegion() == region }
                    let totalMtCO2 = countries.map(\.territorialMtCO2).reduce(0, +)
                    
                    SectorMark(
                        angle: .value(region.rawValue, totalMtCO2),
                        innerRadius: .ratio(0.618),
                        outerRadius: .inset(20),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Region", region.rawValue))
                }
            }.frame(height: 400)
        }.chartBackgroundStyle()
    }
    
    private var ndGainScoreByRegionChart: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ChartType.ndGainScoreByRegion.rawValue)
                .customFont(size: 20, weight: .bold)
            
            Text(ChartType.ndGainScoreByRegion.description)
                .customFont(size: 18)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            Chart {
                ForEach(Region.allCases) { region in
                    let countries = countryDataManager.countries.filter { $0.getRegion() == region }
                    let totalNDGainScore = countries.map(\.NDGainScore).reduce(0, +)
                    
                    SectorMark(
                        angle: .value(region.rawValue, totalNDGainScore),
                        innerRadius: .ratio(0.618),
                        outerRadius: .inset(20),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Region", region.rawValue))
                }
            }.frame(height: 400)
        }.chartBackgroundStyle()
    }
    
    private var climaJusticeScoreByRegionChart: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ChartType.climaJusticeScoreByRegion.rawValue)
                .customFont(size: 20, weight: .bold)
            
            Text(ChartType.climaJusticeScoreByRegion.description)
                .customFont(size: 18)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            Chart {
                let (minLog, rangeLog) = self.countryDataManager.countries.logCO2Scaling()
                
                ForEach(Region.allCases) { region in
                    let countries = countryDataManager.countries.filter { $0.getRegion() == region }
                    let totalClimaJusticeScore = countries.map { $0.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog) }.reduce(0, +)
                    
                    SectorMark(
                        angle: .value(region.rawValue, totalClimaJusticeScore),
                        innerRadius: .ratio(0.618),
                        outerRadius: .inset(20),
                        angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Region", region.rawValue))
                }
            }.frame(height: 400)
        }.chartBackgroundStyle()
    }
    
    // MARK: Comparative Charts
    private var territorialMtCO2vsNDGainScoreChart: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ChartType.territorialMtCO2vsNDGainScore.rawValue)
                .customFont(size: 20, weight: .bold)
            
            Text(ChartType.territorialMtCO2vsNDGainScore.description)
                .customFont(size: 18)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            Chart {
                ForEach(self.countryDataManager.countries) { country in
                    PointMark(
                        x: .value("Territorial MtCO2", country.territorialMtCO2),
                        y: .value("ND-Gain Score", country.NDGainScore)
                    )
                    .foregroundStyle(by: .value("Region", country.getRegion().rawValue))
                    .symbolSize(60)
                }
            }
            .chartXScale(domain: 0...800)
            .chartYScale(domain: 25...75)
            .chartXAxis {
                AxisMarks(values: [0, 200, 400, 600, 800]) {
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
            .chartYAxis {
                AxisMarks(values: [25, 35, 45, 55, 65, 75]) {
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
            .frame(height: 600)
            
            Label("Extreme outliers (China, US, Russia, Japan) omitted for visual clarity", systemImage: "info.circle")
                .customFont(size: 14, weight: .medium)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }.chartBackgroundStyle()
    }
    
    private var territorialMtCO2vsClimaJusticeScoreChart: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ChartType.territorialMtCO2vsClimaJusticeScore.rawValue)
                .customFont(size: 20, weight: .bold)
            
            Text(ChartType.territorialMtCO2vsClimaJusticeScore.description)
                .customFont(size: 18)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            Chart {
                let (minLog, rangeLog) = self.countryDataManager.countries.logCO2Scaling()
                
                ForEach(self.countryDataManager.countries) { country in
                    PointMark(
                        x: .value("Territorial MtCO2", country.territorialMtCO2),
                        y: .value("Clima Justice Score", country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog))
                    )
                    .foregroundStyle(by: .value("Region", country.getRegion().rawValue))
                    .symbolSize(60)
                }
            }
            .chartXScale(domain: 0...800)
            .chartYScale(domain: 30...80)
            .chartXAxis {
                AxisMarks(values: [0, 200, 400, 600, 800]) {
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 20, 40, 60, 80]) {
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
            .frame(height: 600)
            
            Label("Extreme outliers (China, US, Russia, Japan) omitted for visual clarity", systemImage: "info.circle")
                .customFont(size: 14, weight: .medium)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }.chartBackgroundStyle()
    }
    
    private var ndGainScorevsClimaJusticeScoreChart: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ChartType.ndGainScorevsClimaJusticeScore.rawValue)
                .customFont(size: 20, weight: .bold)
            
            Text(ChartType.ndGainScorevsClimaJusticeScore.description)
                .customFont(size: 18)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            Chart {
                let (minLog, rangeLog) = self.countryDataManager.countries.logCO2Scaling()
                
                ForEach(self.countryDataManager.countries) { country in
                    PointMark(
                        x: .value("ND-Gain Score", country.NDGainScore),
                        y: .value("Clima Justice Score", country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog))
                    )
                    .foregroundStyle(by: .value("Region", country.getRegion().rawValue))
                    .symbolSize(60)
                }
            }
            .chartXScale(domain: 25...75)
            .chartYScale(domain: 0...80)
            .chartXAxis {
                AxisMarks(values: [25, 35, 45, 55, 65, 75]) {
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
            .chartYAxis {
                AxisMarks(values: [0, 20, 40, 60, 80]) {
                    AxisValueLabel()
                    AxisGridLine()
                }
            }
            .frame(height: 600)
        }.chartBackgroundStyle()
    }
    
    @ViewBuilder
    private func getChartView(for type: ChartType) -> some View {
        switch type {
        case .top10CountriesByTerritorialMtCO2:
            top10CountriesByTerritorialMtCO2Chart
        case .top10CountriesByNDGainScore:
            top10CountriesByNDGainScoreChart
        case .top10CountriesByClimaJusticeScore:
            top10CountriesByClimaJusticeScoreChart
        case .bottom10CountriesByClimaJusticeScore:
            bottom10CountriesByClimaJusticeScoreChart
        case .territorialMtCO2ByRegion:
            territorialMtCO2ByRegionChart
        case .ndGainScoreByRegion:
            ndGainScoreByRegionChart
        case .climaJusticeScoreByRegion:
            climaJusticeScoreByRegionChart
        case .territorialMtCO2vsNDGainScore:
            territorialMtCO2vsNDGainScoreChart
        case .territorialMtCO2vsClimaJusticeScore:
            territorialMtCO2vsClimaJusticeScoreChart
        case .ndGainScorevsClimaJusticeScore:
            ndGainScorevsClimaJusticeScoreChart
        }
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

fileprivate extension View {
    func chartBackgroundStyle() -> some View {
        self
            .padding(25)
            .background(Material.ultraThin)
            .cornerRadius(20, corners: .allCorners)
            .padding(.horizontal)
            .transition(.blurReplace)
    }
}

#Preview {
    ChartsView()
        .environmentObject(CountryDataManager())
}
