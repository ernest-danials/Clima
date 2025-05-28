//
//  CompareView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-25.
//

import SwiftUI

struct CompareView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    
    @State private var selectedCountryOnLeft: Country? = nil
    @State private var searchTextOnLeft: String = ""
    @State private var currentListSortOptionOnLeft: CountrySortOption = .nameAtoZ
    private var displayedCountriesOnLeft: [Country] {
        return self.countryDataManager.countries.getFilteredAndSortedCountries(countryDataManager: self.countryDataManager, searchText: self.searchTextOnLeft, sortingOption: self.currentListSortOptionOnLeft)
    }
    
    @State private var selectedCountryOnRight: Country? = nil
    @State private var searchTextOnRight: String = ""
    @State private var currentListSortOptionOnRight: CountrySortOption = .nameAtoZ
    private var displayedCountriesOnRight: [Country] {
        return self.countryDataManager.countries.getFilteredAndSortedCountries(countryDataManager: self.countryDataManager, searchText: self.searchTextOnRight, sortingOption: self.currentListSortOptionOnRight)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                HStack(alignment: .top, spacing: 15) {
                    // MARK: Left Country List
                    VStack {
                        countryListHeader(for: .left)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                if !displayedCountriesOnLeft.isEmpty {
                                    ForEach(displayedCountriesOnLeft) { country in
                                        let isSelected = self.selectedCountryOnLeft == country
                                        let isDuplicate = self.selectedCountryOnRight == country
                                        
                                        Button {
                                            selectCountry(isSelected ? nil : country, for: .left)
                                        } label: {
                                            CountryCard(country)
                                                .overlay(alignment: .trailing) {
                                                    if isSelected {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundStyle(Color.accentColor)
                                                            .background(Color.white, in: Circle())
                                                            .padding(.trailing)
                                                    }
                                                }
                                        }
                                        .scaleButtonStyle()
                                        .disabled(isDuplicate)
                                        .opacity(isDuplicate ? 0.5 : 1.0)
                                    }
                                } else {
                                    ContentUnavailableView.search(text: searchTextOnLeft)
                                }
                            }
                        }.prioritiseScaleButtonStyle()
                    }
                    
                    // MARK: Comparison Area
                    VStack(spacing: 20) {
                        Text("Comparing")
                            .customFont(size: 20, weight: .bold)
                        
                        if let leftCountry = selectedCountryOnLeft, let rightCountry = selectedCountryOnRight {
                            comparisonView(leftCountry: leftCountry, rightCountry: rightCountry)
                                .transition(.blurReplace)
                        } else {
                            ContentUnavailableView("Select Two Countries", systemImage: "arrow.left.arrow.right", description: Text("Choose a country from each list to compare their climate data"))
                                .transition(.blurReplace)
                        }
                    }
                    .frame(minWidth: geo.size.width / 3)
                    .padding()
                    .background(Material.ultraThin)
                    .cornerRadius(20, corners: .allCorners)
                    
                    // MARK: Right Country List
                    VStack {
                        countryListHeader(for: .right)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                if !displayedCountriesOnRight.isEmpty {
                                    ForEach(displayedCountriesOnRight) { country in
                                        let isSelected = self.selectedCountryOnRight == country
                                        let isDuplicate = self.selectedCountryOnLeft == country
                                        
                                        Button {
                                            selectCountry(isSelected ? nil : country, for: .right)
                                        } label: {
                                            CountryCard(country)
                                                .overlay(alignment: .trailing) {
                                                    if isSelected {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundStyle(Color.accentColor)
                                                            .background(Color.white, in: Circle())
                                                            .padding(.trailing)
                                                    }
                                                }
                                        }
                                        .scaleButtonStyle()
                                        .disabled(isDuplicate)
                                        .opacity(isDuplicate ? 0.5 : 1.0)
                                    }
                                } else {
                                    ContentUnavailableView.search(text: searchTextOnRight)
                                }
                            }
                        }.prioritiseScaleButtonStyle()
                    }
                }
                .safeAreaPadding(.horizontal)
                .navigationTitle("Compare")
            }
        }
    }
    
    private enum ListOption { case left, right }
    
    private func selectCountry(_ country: Country?, for listOption: ListOption) {
        withAnimation {
            switch listOption {
            case .left:
                self.selectedCountryOnLeft = country
            case .right:
                self.selectedCountryOnRight = country
            }
        }
    }
    
    private func countryListHeader(for listOption: ListOption) -> some View {
        VStack(spacing: 10) {
            Text(listOption == .left ? "Country A" : "Country B")
                .customFont(size: 20, weight: .bold)
                .alignView(to: .leading)
            
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    TextField("Search", text: listOption == .left ? $searchTextOnLeft : $searchTextOnRight)
                    
                    Spacer()
                    
                    let searchText = listOption == .left ? searchTextOnLeft : searchTextOnRight
                    if !searchText.isEmpty {
                        Button {
                            withAnimation {
                                if listOption == .left {
                                    self.searchTextOnLeft.removeAll()
                                } else {
                                    self.searchTextOnRight.removeAll()
                                }
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                        .scaleButtonStyle()
                        .transition(.blurReplace)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Material.ultraThin)
                .cornerRadius(12, corners: .allCorners)
                
                Menu {
                    Section("Sort by") {
                        Menu("Name", systemImage: "character") {
                            Button {
                                changeListSortOption(to: .nameAtoZ, for: listOption)
                            } label: {
                                Label("A to Z", systemImage: (listOption == .left ? currentListSortOptionOnLeft : currentListSortOptionOnRight) == .nameAtoZ ? "checkmark" : "arrow.down")
                            }
                            
                            Button {
                                changeListSortOption(to: .nameZtoA, for: listOption)
                            } label: {
                                Label("Z to A", systemImage: (listOption == .left ? currentListSortOptionOnLeft : currentListSortOptionOnRight) == .nameZtoA ? "checkmark" : "arrow.up")
                            }
                        }
                        
                        Menu("Clima Justice Score", systemImage: "scale.3d") {
                            Button {
                                changeListSortOption(to: .climaJusticeScoreHighToLow, for: listOption)
                            } label: {
                                Label("High to Low", systemImage: (listOption == .left ? currentListSortOptionOnLeft : currentListSortOptionOnRight) == .climaJusticeScoreHighToLow ? "checkmark" : "arrow.down")
                            }
                            
                            Button {
                                changeListSortOption(to: .climaJusticeScoreLowToHigh, for: listOption)
                            } label: {
                                Label("Low to High", systemImage: (listOption == .left ? currentListSortOptionOnLeft : currentListSortOptionOnRight) == .climaJusticeScoreLowToHigh ? "checkmark" : "arrow.up")
                            }
                        }
                        
                        Menu("ND-Gain Score", systemImage: "shield.lefthalf.filled") {
                            Button {
                                changeListSortOption(to: .ndGainScoreHighToLow, for: listOption)
                            } label: {
                                Label("High to Low", systemImage: (listOption == .left ? currentListSortOptionOnLeft : currentListSortOptionOnRight) == .ndGainScoreHighToLow ? "checkmark" : "arrow.down")
                            }
                            
                            Button {
                                changeListSortOption(to: .ndGainScoreLowToHigh, for: listOption)
                            } label: {
                                Label("Low to High", systemImage: (listOption == .left ? currentListSortOptionOnLeft : currentListSortOptionOnRight) == .ndGainScoreLowToHigh ? "checkmark" : "arrow.up")
                            }
                        }
                        
                        Menu("Territorial MtCO2", systemImage: "carbon.dioxide.cloud.fill") {
                            Button {
                                changeListSortOption(to: .territorialMtCO2HighToLow, for: listOption)
                            } label: {
                                Label("High to Low", systemImage: (listOption == .left ? currentListSortOptionOnLeft : currentListSortOptionOnRight) == .territorialMtCO2HighToLow ? "checkmark" : "arrow.down")
                            }
                            
                            Button {
                                changeListSortOption(to: .territorialMtCO2LowToHigh, for: listOption)
                            } label: {
                                Label("Low to High", systemImage: (listOption == .left ? currentListSortOptionOnLeft : currentListSortOptionOnRight) == .territorialMtCO2LowToHigh ? "checkmark" : "arrow.up")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .customFont(size: 16, weight: .semibold)
                }
                .scaleButtonStyle(scaleAmount: 0.92)
            }
        }
        .padding(.top)
    }
    
    private func comparisonView(leftCountry: Country, rightCountry: Country) -> some View {
        let (minLog, rangeLog) = countryDataManager.countries.logCO2Scaling()
        let leftClimaJusticeScore = leftCountry.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)
        let rightClimaJusticeScore = rightCountry.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)
        
        return ScrollView {
            VStack(spacing: 20) {
                // Country Names and Flags
                HStack(spacing: 20) {
                    VStack {
                        AsyncImage(url: URL(string: "https://cdn.ipregistry.co/flags/wikimedia/\(leftCountry.id).png")!) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 60)
                        .cornerRadius(5, corners: .allCorners)
                        
                        Text(leftCountry.name)
                            .customFont(size: 14, weight: .bold)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .contentTransition(.numericText())
                    }.alignView(to: .center)
                    
                    Image(systemName: "arrow.left.arrow.right")
                        .customFont(size: 20, weight: .medium)
                    
                    VStack {
                        AsyncImage(url: URL(string: "https://cdn.ipregistry.co/flags/wikimedia/\(rightCountry.id).png")!) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 60)
                        .cornerRadius(5, corners: .allCorners)
                        
                        Text(rightCountry.name)
                            .customFont(size: 14, weight: .bold)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .contentTransition(.numericText())
                    }.alignView(to: .center)
                }
                
                // Clima Justice Score Comparison
                comparisonMetric(
                    title: "Clima Justice Score",
                    icon: "scale.3d",
                    leftValue: leftClimaJusticeScore,
                    rightValue: rightClimaJusticeScore,
                    format: "%.1f",
                    isHigherBetter: true
                )
                
                // ND-Gain Score Comparison
                comparisonMetric(
                    title: "ND-Gain Score",
                    icon: "shield.lefthalf.filled",
                    leftValue: leftCountry.NDGainScore,
                    rightValue: rightCountry.NDGainScore,
                    format: "%.1f",
                    isHigherBetter: true
                )
                
                // Territorial MtCO2 Comparison
                comparisonMetric(
                    title: "Territorial MtCO2",
                    icon: "carbon.dioxide.cloud.fill",
                    leftValue: leftCountry.territorialMtCO2,
                    rightValue: rightCountry.territorialMtCO2,
                    format: "%.1f",
                    isHigherBetter: false
                )
                
                // Region Comparison
                HStack {
                    VStack(alignment: .leading) {
                        Text("Region")
                            .customFont(size: 12, weight: .medium)
                            .foregroundStyle(.secondary)
                        
                        Text(leftCountry.getRegion().rawValue)
                            .customFont(size: 14, weight: .semibold)
                            .contentTransition(.numericText())
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Region")
                            .customFont(size: 12, weight: .medium)
                            .foregroundStyle(.secondary)
                        
                        Text(rightCountry.getRegion().rawValue)
                            .customFont(size: 14, weight: .semibold)
                            .contentTransition(.numericText())
                    }
                }
                .padding()
                .background(Material.ultraThin)
                .cornerRadius(12, corners: .allCorners)
            }
        }
    }
    
    private func comparisonMetric(title: String, icon: String, leftValue: Double, rightValue: Double, format: String, isHigherBetter: Bool) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .customFont(size: 16, weight: .medium)
                    .foregroundStyle(.secondary)
                
                Text(title)
                    .customFont(size: 14, weight: .semibold)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(String(format: format, leftValue))
                        .customFont(size: 18, weight: .bold)
                        .foregroundStyle(getComparisonColor(value: leftValue, otherValue: rightValue, isHigherBetter: isHigherBetter))
                        .contentTransition(.numericText(value: leftValue))
                    
                    if leftValue != rightValue {
                        Text(getComparisonText(value: leftValue, otherValue: rightValue, isHigherBetter: isHigherBetter, format: format))
                            .customFont(size: 12, weight: .medium)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(format: format, rightValue))
                        .customFont(size: 18, weight: .bold)
                        .foregroundStyle(getComparisonColor(value: rightValue, otherValue: leftValue, isHigherBetter: isHigherBetter))
                        .contentTransition(.numericText(value: rightValue))
                    
                    if leftValue != rightValue {
                        Text(getComparisonText(value: rightValue, otherValue: leftValue, isHigherBetter: isHigherBetter, format: format))
                            .customFont(size: 12, weight: .medium)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Material.ultraThin)
        .cornerRadius(12, corners: .allCorners)
    }
    
    private func getComparisonColor(value: Double, otherValue: Double, isHigherBetter: Bool) -> Color {
        if value == otherValue {
            return .primary
        }
        
        let isBetter = isHigherBetter ? value > otherValue : value < otherValue
        return isBetter ? .green : .red
    }
    
    private func getComparisonText(value: Double, otherValue: Double, isHigherBetter: Bool, format: String) -> String {
        let difference = abs(value - otherValue)
        let percentDifference = (difference / min(value, otherValue)) * 100
        
        // Arrow reflects absolute difference only (not whether it's "better")
        let symbol = value > otherValue ? "↑" : "↓"
        
        return "\(symbol) \(String(format: format, difference)) (\(String(format: "%.1f", percentDifference))%)"
    }
    
    private func changeListSortOption(to option: CountrySortOption, for listOption: ListOption) {
        withAnimation {
            switch listOption {
            case .left:
                self.currentListSortOptionOnLeft = option
            case .right:
                self.currentListSortOptionOnRight = option
            }
        }
    }
}

#Preview {
    CompareView()
        .environmentObject(CountryDataManager())
}
