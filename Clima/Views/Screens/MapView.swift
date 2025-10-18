//
//  MapView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI
import MapKit
import UniversalGlass

struct MapView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    
    @available(*, deprecated, message: "Blocking MapView when in portrait has been removed.")
    @State private var currentDeviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    @State private var selectedCountry: Country? = nil
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var searchText: String = ""
    @State private var isShowingDetailView: Bool = true
    
    @State private var isShowingCountryListSortView: Bool = false
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
    
    let showList: Bool
    let showDetails: Bool
    let showAnnotations: Bool
    
    init(showList: Bool = true, showDetails: Bool = true, showAnnotations: Bool = true) {
        self.showList = showList
        self.showDetails = showDetails
        self.showAnnotations = showAnnotations
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
                        
                        if self.showAnnotations {
                            Annotation(country.name, coordinate: country.getCoordinate()) {}
                        }
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
                    if self.isShowingDetailView && self.showDetails {
                        countryDetailView(geo: geo)
                            .transition(.move(edge: .leading).combined(with: .blurReplace))
                    }
                    
                    Spacer()
                    
                    // MARK: Country List
                    if self.showList {
                        VStack {
                            ScrollViewReader { scrollProxy in
                                countryListHeader(scrollProxy: scrollProxy)
                                    .padding(.bottom, 10)
                                
                                ScrollView {
                                    LazyVStack(alignment: .leading) {
                                        if !displayedCountriesOnList.isEmpty {
                                            ForEach(displayedCountriesOnList) { country in
                                                Button {
                                                    changeSelectedCountry(to: country)
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
                        //.glassEffect(in: RoundedRectangle(cornerRadius: 20))
                        .universalGlassEffect(in: RoundedRectangle(cornerRadius: 20))
                        .cornerRadius(20, corners: .allCorners)
                    }
                }
                .frame(maxHeight: geo.size.height)
                .padding(.trailing, 20)
            }
//            .overlay {
//                if self.currentDeviceOrientation.isPortrait {
//                    ContentUnavailableView("Rotate to Explore", systemImage: "rectangle.portrait.rotate", description: Text("The Clima Map is optimised for landscape orientation. Please rotate your device to explore the map."))
//                        .background(Material.ultraThin)
//                        .ignoresSafeArea()
//                }
//            }
        }
        .safeAreaPadding(.all, 20)
//        .onRotate { newOrientation in
//            withAnimation {
//                self.currentDeviceOrientation = newOrientation
//            }
//        }
    }
    
    @ViewBuilder
    private func countryDetailView(geo: GeometryProxy) -> some View {
        VStack {
            if let country = self.selectedCountry {
                countryDetailViewContent(country: country)
            } else {
                ContentUnavailableView("Select a Country", systemImage: "flag.fill", description: Text("Select a country from the list to view its details"))
                    .transition(.blurReplace)
            }
        }
        .frame(width: min(300, geo.size.width / 4))
        .scrollIndicators(.hidden)
        .safeAreaPadding(25)
        //.glassEffect(in: RoundedRectangle(cornerRadius: 20))
        .universalGlassEffect(in: RoundedRectangle(cornerRadius: 20))
        .onChange(of: self.mapCameraPosition) { _, _ in
            if self.selectedCountry == nil && self.mapCameraPosition != .automatic {
                withAnimation(.spring) {
                    self.isShowingDetailView = false
                }
            }
        }
    }
    
    @ViewBuilder
    private func countryDetailViewContent(country: Country) -> some View {
        ScrollView {
            let (minLog, rangeLog) = self.countryDataManager.countries.logCO2Scaling()
            let climaJusticeScore = country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)
            
            VStack(spacing: 15) {
                Spacer().frame(height: 10)
                
                AsyncImage(url: URL(string: "https://cdn.ipregistry.co/flags/wikimedia/\(country.id).png")!) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80)
                .cornerRadius(5, corners: .allCorners)
                
                VStack {
                    let rank = self.countryDataManager.getCountryClimaJusticeScoreRank(for: country)
                    let totalCountries = self.countryDataManager.countries.count
                    
                    Text("#\(rank)/\(totalCountries)")
                        .customFont(size: 20, weight: .semibold)
                        .foregroundStyle(.gray)
                        .contentTransition(.numericText(value: Double(rank)))
                    
                    Text(country.name)
                        .customFont(size: 27, weight: .bold)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.4)
                        .contentTransition(.numericText())
                    
                    Text(country.getRegion().rawValue)
                        .customFont(size: 17, weight: .medium)
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
    }
    
    private func countryListHeader(scrollProxy: ScrollViewProxy) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("Clima")
                    .customFont(size: 30, weight: .heavy)
                
                Spacer()
                
                Button {
                    changeSelectedCountry(to: nil)
                } label: {
                    Image(systemName: "xmark")
                        .customFont(size: 20, weight: .semibold)
                        .padding(5)
                }
                .contentShape(.rect)
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
                
                Button {
                    self.isShowingCountryListSortView = true
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .customFont(size: 20, weight: .semibold)
                        .padding(5)
                }
                .contentShape(.rect)
                .scaleButtonStyle(scaleAmount: 0.92)
                .sheet(isPresented: $isShowingCountryListSortView) {
                    countryListSortView(scrollProxy: scrollProxy)
                }
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
    
    @ViewBuilder
    private func countryListSortView(scrollProxy: ScrollViewProxy) -> some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        changeListSortOption(to: .nameAtoZ)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let id = self.displayedCountriesOnList.first?.id {
                                withAnimation { scrollProxy.scrollTo(id) }
                            }
                        }
                    } label: {
                        HStack {
                            Label("A to Z", systemImage: "arrow.down")
                            Spacer()
                            if self.currentListSortOption == .nameAtoZ {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Button {
                        changeListSortOption(to: .nameZtoA)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let id = self.displayedCountriesOnList.first?.id {
                                withAnimation { scrollProxy.scrollTo(id) }
                            }
                        }
                    } label: {
                        HStack {
                            Label("Z to A", systemImage: "arrow.up")
                            Spacer()
                            if self.currentListSortOption == .nameZtoA {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } header: {
                    Label("Name", systemImage: "character")
                }
                
                Section {
                    Button {
                        changeListSortOption(to: .climaJusticeScoreHighToLow)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let id = self.displayedCountriesOnList.first?.id {
                                withAnimation { scrollProxy.scrollTo(id) }
                            }
                        }
                    } label: {
                        HStack {
                            Label("High to Low", systemImage: "arrow.down.right")
                            Spacer()
                            if self.currentListSortOption == .climaJusticeScoreHighToLow {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Button {
                        changeListSortOption(to: .climaJusticeScoreLowToHigh)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let id = self.displayedCountriesOnList.first?.id {
                                withAnimation { scrollProxy.scrollTo(id) }
                            }
                        }
                    } label: {
                        HStack {
                            Label("Low to High", systemImage: "arrow.up.right")
                            Spacer()
                            if self.currentListSortOption == .climaJusticeScoreLowToHigh {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } header: {
                    Label("Clima Justice Score", systemImage: "scale.3d")
                }
                
                Section {
                    Button {
                        changeListSortOption(to: .ndGainScoreHighToLow)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let id = self.displayedCountriesOnList.first?.id {
                                withAnimation { scrollProxy.scrollTo(id) }
                            }
                        }
                    } label: {
                        HStack {
                            Label("High to Low", systemImage: "arrow.down.right")
                            Spacer()
                            if self.currentListSortOption == .ndGainScoreHighToLow {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Button {
                        changeListSortOption(to: .ndGainScoreLowToHigh)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let id = self.displayedCountriesOnList.first?.id {
                                withAnimation { scrollProxy.scrollTo(id) }
                            }
                        }
                    } label: {
                        HStack {
                            Label("Low to High", systemImage: "arrow.up.right")
                            Spacer()
                            if self.currentListSortOption == .ndGainScoreLowToHigh {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } header: {
                    Label("ND-Gain Score", systemImage: "shield.lefthalf.filled")
                }
                
                Section {
                    Button {
                        changeListSortOption(to: .territorialMtCO2HighToLow)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let id = self.displayedCountriesOnList.first?.id {
                                withAnimation { scrollProxy.scrollTo(id) }
                            }
                        }
                    } label: {
                        HStack {
                            Label("High to Low", systemImage: "arrow.down.right")
                            Spacer()
                            if self.currentListSortOption == .territorialMtCO2HighToLow {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Button {
                        changeListSortOption(to: .territorialMtCO2LowToHigh)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let id = self.displayedCountriesOnList.first?.id {
                                withAnimation { scrollProxy.scrollTo(id) }
                            }
                        }
                    } label: {
                        HStack {
                            Label("Low to High", systemImage: "arrow.up.right")
                            Spacer()
                            if self.currentListSortOption == .territorialMtCO2LowToHigh {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } header: {
                    Label("Territorial MtCO2", systemImage: "carbon.dioxide.cloud.fill")
                }
            }
            .safeAreaPadding(.bottom)
            .listStyle(.insetGrouped)
            .navigationTitle("Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button {
                            self.isShowingCountryListSortView = false
                        } label: {
                            Image(systemName: "checkmark")
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.glassProminent)
                    } else {
                        Button("Done") {
                            self.isShowingCountryListSortView = false
                        }
                    }
                }
            }
        }
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
