//
//  OnboardingView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-28.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    
    @State private var currentStatus: OnboardingViewStatus = .thisIsCompare
    
    private var continueLabelString: String {
        if self.currentStatus == .welcomeToClima {
            return "Tap anywhere to begin"
        } else {
            return "Tap anywhere to continue. Double tap to go back."
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                ZStack {
                    if self.currentStatus == .welcomeToClima {
                        VStack(alignment: .center) {
                            Text("Welcome to")
                                .customFont(size: 25, weight: .medium)
                            
                            Text("Clima")
                                .customFont(size: 35, weight: .heavy)
                        }.transition(.blurReplace)
                    } else if self.currentStatus == .whatIsClima {
                        VStack(alignment: .center) {
                            Text("Clima is an")
                                .customFont(size: 25, weight: .medium)
                                .foregroundStyle(.secondary)
                            
                            Text("Interactive, educational app about")
                                .customFont(size: 30, weight: .medium)
                            
                            Text("Climate Justice")
                                .customFont(size: 35, weight: .heavy)
                            
                            Text("Climate Justice discusses about the disproportionate impacts of climate change")
                                .customFont(size: 20, weight: .medium)
                                .padding(.top, 2)
                        }.transition(.blurReplace)
                    } else if self.currentStatus == .thisIsMap {
                        HStack(spacing: 5) {
                            MapView(showList: false, showDetails: false, showAnnotations: false)
                                .frame(width: geo.size.width / 2.5)
                                .cornerRadius(20, corners: .allCorners)
                                .padding()
                                .background(Material.ultraThin)
                                .cornerRadius(20, corners: .allCorners)
                            
                            VStack(alignment: .leading) {
                                Text("This is the")
                                    .customFont(size: 25, weight: .medium)
                                    .foregroundStyle(.secondary)
                                
                                Text("Map,")
                                    .customFont(size: 35, weight: .heavy)
                                
                                Text("where you can understand about climate justice visually")
                                    .customFont(size: 20, weight: .medium)
                                    .padding(.bottom)
                                
                                Text("""
                            In terms of climate justice,
                            ⋅ The more red the country's circle is, the worse.
                            ⋅ The bigger the country's circle is, the worse.
                            """)
                                .customFont(size: 18, weight: .regular)
                            }
                            .frame(width: geo.size.width / 2.5)
                        }
                        .padding()
                        .transition(.blurReplace)
                    } else if self.currentStatus == .thisIsCharts {
                        HStack(spacing: 15) {
                            ZStack {
                                ChartsView.getChartView(for: .climaJusticeScoreByRegion, countryDataManager: self.countryDataManager)
                                    .rotationEffect(.degrees(-10))
                                
                                ChartsView.getChartView(for: .top10CountriesByClimaJusticeScore, countryDataManager: self.countryDataManager)
                                    .rotationEffect(.degrees(-4))
                                
                                ChartsView.getChartView(for: .ndGainScorevsClimaJusticeScore, countryDataManager: self.countryDataManager)
                                    .rotationEffect(.degrees(5))
                            }
                            .redacted(reason: .placeholder)
                            .frame(width: geo.size.width / 2.1)
                            
                            VStack(alignment: .leading) {
                                Text("These are the")
                                    .customFont(size: 25, weight: .medium)
                                    .foregroundStyle(.secondary)
                                
                                Text("Charts,")
                                    .customFont(size: 35, weight: .heavy)
                                
                                Text("where you can dive deep into climate justice data")
                                    .customFont(size: 20, weight: .medium)
                                    .padding(.bottom)
                                
                                Text("""
                            The charts include:
                            ⋅ Bar charts showing top/bottom countries by various metrics
                            ⋅ Pie charts displaying regional breakdowns
                            ⋅ Scatter plots comparing different climate indicators
                            """)
                                .customFont(size: 18, weight: .regular)
                            }
                            .frame(width: geo.size.width / 2.5)
                        }
                        .padding()
                        .transition(.blurReplace)
                    } else if self.currentStatus == .thisIsCompare {
                        ZStack {
                            CompareView(isForOnboarding: true)
                            
                            VStack(spacing: 4) {
                                Text("This is")
                                    .customFont(size: 25, weight: .medium)
                                    .foregroundStyle(.secondary)
                                
                                Text("Compare,")
                                    .customFont(size: 35, weight: .heavy)
                                
                                Text("where you can dive deep into climate justice data")
                                    .customFont(size: 20, weight: .medium)
                                    .padding(.bottom)
                            }
                            .padding(35)
                            .background(Material.ultraThin)
                            .cornerRadius(20, corners: .allCorners)
                        }
                        .transition(.blurReplace)
                    }
                }.frame(maxHeight: geo.size.height)
                
                if self.currentStatus == .welcomeToClima || self.currentStatus == .whatIsClima {
                    Text(continueLabelString)
                        .customFont(size: 20)
                        .foregroundStyle(.secondary)
                        .transition(.blurReplace)
                }
            }
            .safeAreaPadding(25)
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(.rect)
            .onTapGesture { changeCurrentStatus() }
            .onTapGesture(count: 2) { changeCurrentStatus(forward: false) }
        }
    }
    
    private func changeCurrentStatus(to status: OnboardingViewStatus) {
        withAnimation(.easeInOut(duration: 0.6)) {
            self.currentStatus = status
        }
    }
    
    private func changeCurrentStatus(forward: Bool = true) {
        withAnimation(.easeInOut(duration: 0.6)) {
            if forward {
                if let nextStatus = currentStatus.getNextStatus() {
                    self.currentStatus = nextStatus
                }
            } else {
                if let previousStatus = currentStatus.getPreviousStatus() {
                    self.currentStatus = previousStatus
                }
            }
        }
    }
    
    private enum OnboardingViewStatus: CaseIterable {
        case welcomeToClima, whatIsClima, beforeWeStart, thisIsMap, thisIsCharts, thisIsCompare
        
        func getNextStatus() -> Self? {
            let allCases = Self.allCases
            guard let currentIndex = allCases.firstIndex(of: self) else { return nil }
            let nextIndex = currentIndex + 1
            return nextIndex < allCases.count ? allCases[nextIndex] : nil
        }
        
        func getPreviousStatus() -> Self? {
            let allCases = Self.allCases
            guard let currentIndex = allCases.firstIndex(of: self) else { return nil }
            let previousIndex = currentIndex - 1
            return previousIndex >= 0 ? allCases[previousIndex] : nil
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(CountryDataManager())
}
