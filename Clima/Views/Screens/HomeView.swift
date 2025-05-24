//
//  HomeView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    
    @State private var selectedCountry: Country? = nil
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var searchText: String = ""
    
    private var displayedCountriesOnMap: [Country] {
        if let selectedCountry = self.selectedCountry {
            return [selectedCountry]
        } else {
            return self.countryDataManager.countries
        }
    }
    
    private var displayedCountriesOnList: [Country] {
        return self.countryDataManager.countries.filter { $0.name.lowercased().replacingOccurrences(of: "ü", with: "u").hasPrefix(self.searchText.lowercased().replacingOccurrences(of: "ü", with: "u")) }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .trailing) {
                Map(position: $mapCameraPosition) {
                    ForEach(self.displayedCountriesOnMap) { country in
                        MapCircle(center: country.getCoordinate(), radius: 500000)
                            .foregroundStyle(.red.opacity(0.3))
                        
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
                    countryDetailView(geo: geo)
                    
                    Spacer()
                    
                    // MARK: Country List
                    VStack {
                        countryListHeader()
                        
                        ScrollView {
                            LazyVStack(alignment: .leading) {
                                if !displayedCountriesOnList.isEmpty {
                                    ForEach(displayedCountriesOnList) { country in
                                        Button {
                                            changeSelectedCountry(to: country)
                                            HapticManager.shared.impact(style: .soft)
                                        } label: {
                                            CountryCard(country)
                                        }
                                        .scaleButtonStyle()
                                    }
                                } else {
                                    countryListNoResultsView()
                                }
                            }
                        }
                        .prioritiseScaleButtonStyle()
                    }
                    .frame(width: max(300, geo.size.width / 3.5))
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
                        
                        Text(country.name)
                            .customFont(size: 27, weight: .bold)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.4)
                            .contentTransition(.numericText())
                        
                        VStack(spacing: 8) {
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
                            Image(systemName: "flag.fill")
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
        .frame(width: max(300, geo.size.width / 3.5))
        .scrollIndicators(.hidden)
        .safeAreaPadding(25)
        .background(Material.ultraThin)
        .cornerRadius(20, corners: .allCorners)
    }
    
    private func countryListHeader() -> some View {
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
                .scaleButtonStyle(scaleAmount: 0.97)
                .disabled(self.selectedCountry == nil)
                .opacity(self.selectedCountry == nil ? 0.0 : 1.0)
            }
            
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
            } else {
                self.selectedCountry = nil
                self.mapCameraPosition = .automatic
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CountryDataManager())
}
