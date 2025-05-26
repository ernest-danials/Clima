//
//  HomeView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    
    @State private var selectedCountry: Country? = nil
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var searchText: String = ""
    @State private var isShowingDetailView: Bool = true
    @State private var currentListSortOption: CountrySortOption = .nameAtoZ
    
    private var displayedCountriesOnMap: [Country] {
        if let selectedCountry = self.selectedCountry {
            return [selectedCountry]
        } else {
            return self.countryDataManager.countries
        }
    }
    
    private var displayedCountriesOnList: [Country] {
        return self.countryDataManager.countries.getFilteredAndSortedCountries(countryDataManager: countryDataManager, searchText: self.searchText, sortingOption: self.currentListSortOption)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .trailing) {
                Map(position: $mapCameraPosition) {
                    ForEach(self.displayedCountriesOnMap) { country in
                        let (minLog, rangeLog) = self.countryDataManager.countries.logCO2Scaling()
                        let climaJusticeScore = country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)
                        
                        MapCircle(center: country.getCoordinate(), radius: 500000 * country.getScaleFactor(for: climaJusticeScore))
                            .foregroundStyle(country.getColorForClimaJusticeScore(climaJusticeScore).opacity(0.5))
                        
                        Annotation(country.name, coordinate: country.getCoordinate()) {}
                    }
                }
                .mapStyle(.imagery(elevation: .realistic))
                .onChange(of: self.mapCameraPosition) { oldValue, newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if let country = self.selectedCountry, self.mapCameraPosition != country.getMapCameraPosition() {
                            withAnimation {
                                self.mapCameraPosition = country.getMapCameraPosition()
                            }
                        }
                    }
                }
                
                HStack {
                    // MARK: Selected Country Detail
                    if self.isShowingDetailView {
                        countryDetailView(geo: geo)
                            .transition(.move(edge: .leading).combined(with: .blurReplace))
                    }
                    
                    Spacer()
                    
                    // MARK: Country List
                    VStack {
                        ScrollViewReader { scrollProxy in
                            countryListHeader(scrollProxy: scrollProxy)
                            
                            ScrollView {
                                LazyVStack(alignment: .leading) {
                                    if !displayedCountriesOnList.isEmpty {
                                        ForEach(displayedCountriesOnList) { country in
                                            Button {
                                                changeSelectedCountry(to: country)
                                                HapticManager.shared.impact(style: .soft)
                                            } label: {
                                                CountryCard(country)
                                                    .opacity(self.selectedCountry == country ? 0.5 : 1.0)
                                            }
                                            .scaleButtonStyle()
                                            .disabled(self.selectedCountry == country)
                                        }
                                    } else {
                                        countryListNoResultsView()
                                    }
                                }
                            }
                            .prioritiseScaleButtonStyle()
                        }
                    }
                    .frame(width: min(300, geo.size.width / 4))
                    .safeAreaPadding(25)
                    .background(Material.ultraThin)
                    .cornerRadius(20, corners: .allCorners)
                }
                .frame(maxHeight: geo.size.height)
                .padding(.trailing, 20)
            }
        }
        .safeAreaPadding(.all, 20)
    }
    
    private func countryDetailView(geo: GeometryProxy) -> some View {
        VStack {
            if let country = self.selectedCountry {
                ScrollView {
                    let (minLog, rangeLog) = self.countryDataManager.countries.logCO2Scaling()
                    let climaJusticeScore = country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)
                    
                    VStack(spacing: 15) {
                        Spacer().frame(height: 10)
                        
                        Image(country.id)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90)
                            .cornerRadius(11, corners: .allCorners)
                        
                        VStack {
                            Text(country.name)
                                .customFont(size: 27, weight: .bold)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.4)
                                .contentTransition(.numericText())
                            
                            Text(country.getRegion().rawValue)
                                .customFont(size: 20, weight: .medium)
                                .foregroundStyle(.gray)
                        }
                        
                        VStack(spacing: 8) {
                            Image(systemName: "scale.3d")
                                .customFont(size: 35)
                                .foregroundStyle(.secondary)
                                
                            Text("Clima Justice Score")
                                .customFont(size: 19, weight: .bold)
                            
                            Text(String(format: "%.1f", climaJusticeScore))
                                .customFont(size: 20, weight: .heavy)
                                .contentTransition(.numericText(value: climaJusticeScore))
                            
                            LinearGradient(colors: [.red, .green], startPoint: .leading, endPoint: .trailing)
                                .frame(height: 10)
                                .cornerRadius(10, corners: .allCorners)
                                .overlay {
                                    GeometryReader { geometry in
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 18, height: 18)
                                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                            .position(
                                                x: geometry.size.width * (climaJusticeScore / 100.0),
                                                y: geometry.size.height / 2
                                            )
                                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: climaJusticeScore)
                                    }
                                }
                        }
                        .alignView(to: .center)
                        .padding()
                        .background(Material.ultraThin)
                        .cornerRadius(16, corners: .allCorners)
                        
                        VStack {
                            Image(systemName: "shield.lefthalf.filled")
                                .customFont(size: 35)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 3)
                            
                            Text("ND-Gain Score")
                                .customFont(size: 17, weight: .medium)
                                .multilineTextAlignment(.center)
                            
                            Text(String(format: "%.1f", country.NDGainScore))
                                .customFont(size: 18, weight: .bold)
                                .contentTransition(.numericText(value: country.NDGainScore))
                        }
                        .alignView(to: .center)
                        .padding()
                        .background(Material.ultraThin)
                        .cornerRadius(16, corners: .allCorners)
                        
                        VStack {
                            Image(systemName: "carbon.dioxide.cloud.fill")
                                .customFont(size: 35)
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 3)
                            
                            Text("Territorial MtCO2")
                                .customFont(size: 17, weight: .medium)
                                .multilineTextAlignment(.center)
                            
                            Text(String(format: "%.1f", country.territorialMtCO2))
                                .customFont(size: 18, weight: .bold)
                                .contentTransition(.numericText(value: country.territorialMtCO2))
                        }
                        .alignView(to: .center)
                        .padding()
                        .background(Material.ultraThin)
                        .cornerRadius(16, corners: .allCorners)
                    }
                }
                .transition(.blurReplace)
            } else {
                ContentUnavailableView("Select a Country", systemImage: "flag.fill", description: Text("Select a country from the list to view its details"))
                    .transition(.blurReplace)
            }
        }
        .frame(width: min(300, geo.size.width / 4))
        .scrollIndicators(.hidden)
        .safeAreaPadding(25)
        .background(Material.ultraThin)
        .cornerRadius(20, corners: .allCorners)
        .onChange(of: self.mapCameraPosition) { _, _ in
            if self.selectedCountry == nil && self.mapCameraPosition != .automatic {
                withAnimation(.spring) {
                    self.isShowingDetailView = false
                }
            }
        }
    }
    
    private func countryListHeader(scrollProxy: ScrollViewProxy) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("Clima")
                    .customFont(size: 30, weight: .heavy)
                
                Spacer()
                
                Button {
                    changeSelectedCountry(to: nil)
                    HapticManager.shared.impact(style: .soft)
                } label: {
                    Image(systemName: "xmark")
                        .customFont(size: 20, weight: .semibold)
                        .foregroundColor(.white)
                }
                .scaleButtonStyle(scaleAmount: 0.96)
                .disabled(self.selectedCountry == nil)
                .opacity(self.selectedCountry == nil ? 0.0 : 1.0)
            }
            
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .fontWeight(.medium)
                    
                    TextField("Search", text: $searchText)
                    
                    Spacer()
                    
                    if !searchText.isEmpty {
                        Button {
                            withAnimation {
                                self.searchText.removeAll()
                                HapticManager.shared.impact(style: .soft)
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .fontWeight(.medium)
                        }
                        .scaleButtonStyle()
                        .transition(.blurReplace)
                    }
                }
                .padding()
                .background(Material.ultraThin)
                .cornerRadius(17, corners: .allCorners)
                .onChange(of: self.searchText) { _, _ in
                    if let id = self.displayedCountriesOnList.first?.id {
                        withAnimation { scrollProxy.scrollTo(id) }
                    }
                }
                
                Menu {
                    Section("Sort by") {
                        Menu("Name", systemImage: "character") {
                            Button {
                                changeListSortOption(to: .nameAtoZ)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if let id = self.displayedCountriesOnList.first?.id {
                                        withAnimation { scrollProxy.scrollTo(id) }
                                    }
                                }
                                HapticManager.shared.impact(style: .soft)
                            } label: {
                                Label("A to Z", systemImage: self.currentListSortOption == .nameAtoZ ? "checkmark" : "arrow.down")
                            }
                            
                            Button {
                                changeListSortOption(to: .nameZtoA)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if let id = self.displayedCountriesOnList.first?.id {
                                        withAnimation { scrollProxy.scrollTo(id) }
                                    }
                                }
                                HapticManager.shared.impact(style: .soft)
                            } label: {
                                Label("Z to A", systemImage: self.currentListSortOption == .nameZtoA ? "checkmark" : "arrow.up")
                            }
                        }
                        
                        Menu("Clima Justice Score", systemImage: "scale.3d") {
                            Button {
                                changeListSortOption(to: .climaJusticeScoreHighToLow)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if let id = self.displayedCountriesOnList.first?.id {
                                        withAnimation { scrollProxy.scrollTo(id) }
                                    }
                                }
                                HapticManager.shared.impact(style: .soft)
                            } label: {
                                Label("High to Low", systemImage: self.currentListSortOption == .climaJusticeScoreHighToLow ? "checkmark" : "arrow.down")
                            }
                            
                            Button {
                                changeListSortOption(to: .climaJusticeScoreLowToHigh)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if let id = self.displayedCountriesOnList.first?.id {
                                        withAnimation { scrollProxy.scrollTo(id) }
                                    }
                                }
                                HapticManager.shared.impact(style: .soft)
                            } label: {
                                Label("Low to High", systemImage: self.currentListSortOption == .climaJusticeScoreLowToHigh ? "checkmark" : "arrow.up")
                            }
                        }
                        
                        Menu("ND-Gain Score", systemImage: "shield.lefthalf.filled") {
                            Button {
                                changeListSortOption(to: .ndGainScoreHighToLow)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if let id = self.displayedCountriesOnList.first?.id {
                                        withAnimation { scrollProxy.scrollTo(id) }
                                    }
                                }
                                HapticManager.shared.impact(style: .soft)
                            } label: {
                                Label("High to Low", systemImage: self.currentListSortOption == .ndGainScoreHighToLow ? "checkmark" : "arrow.down")
                            }
                            
                            Button {
                                changeListSortOption(to: .ndGainScoreLowToHigh)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if let id = self.displayedCountriesOnList.first?.id {
                                        withAnimation { scrollProxy.scrollTo(id) }
                                    }
                                }
                                HapticManager.shared.impact(style: .soft)
                            } label: {
                                Label("Low to High", systemImage: self.currentListSortOption == .ndGainScoreLowToHigh ? "checkmark" : "arrow.up")
                            }
                        }
                        
                        Menu("Territorial MtCO2", systemImage: "carbon.dioxide.cloud.fill") {
                            Button {
                                changeListSortOption(to: .territorialMtCO2HighToLow)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if let id = self.displayedCountriesOnList.first?.id {
                                        withAnimation { scrollProxy.scrollTo(id) }
                                    }
                                }
                                HapticManager.shared.impact(style: .soft)
                            } label: {
                                Label("High to Low", systemImage: self.currentListSortOption == .territorialMtCO2HighToLow ? "checkmark" : "arrow.down")
                            }
                            
                            Button {
                                changeListSortOption(to: .territorialMtCO2LowToHigh)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if let id = self.displayedCountriesOnList.first?.id {
                                        withAnimation { scrollProxy.scrollTo(id) }
                                    }
                                }
                                HapticManager.shared.impact(style: .soft)
                            } label: {
                                Label("Low to High", systemImage: self.currentListSortOption == .territorialMtCO2LowToHigh ? "checkmark" : "arrow.up")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .customFont(size: 20, weight: .semibold)
                }
                .scaleButtonStyle(scaleAmount: 0.92)
                .simultaneousGesture(TapGesture().onEnded {
                    HapticManager.shared.impact(style: .soft)
                })
            }
        }
    }
    
    private func countryListNoResultsView() -> some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .customFont(size: 28, weight: .semibold)
            
            Text("No Results")
                .customFont(size: 20, weight: .semibold)
            
            Text("No countries found. Clima only supports a search for prefixes of country names.")
                .customFont(size: 15, weight: .medium)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(.vertical, 20)
        .alignView(to: .center)
    }
    
    private func changeSelectedCountry(to country: Country?) {
        withAnimation {
            if let country = country {
                self.selectedCountry = country
                self.mapCameraPosition = country.getMapCameraPosition()
                self.isShowingDetailView = true
            } else {
                self.selectedCountry = nil
                self.mapCameraPosition = .automatic
            }
        }
    }
    
    private func changeListSortOption(to option: CountrySortOption) {
        withAnimation {
            self.currentListSortOption = option
        }
    }
}

#Preview {
    MapView()
        .environmentObject(CountryDataManager())
}
