//
//  Country.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI
import MapKit

struct Country: Identifiable, Equatable, Decodable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let territorialMtCO2: Double
    let NDGainScore: Double
}

extension Country {
    func getRegion() -> Region {
        switch self.id.lowercased() {
        // Africa
        case "dz", "ao", "bj", "bw", "bf", "bi", "cm", "cv", "cf", "td", "km", "cg", "cd", "ci", "dj", "eg", "gq", "er", "et", "ga", "gm", "gh", "gn", "gw", "ke", "ls", "lr", "ly", "mg", "mw", "ml", "mr", "mu", "ma", "mz", "na", "ne", "ng", "rw", "st", "sn", "sc", "sl", "so", "za", "ss", "sd", "sz", "tz", "tg", "tn", "ug", "zm", "zw":
            return .africa
            
        // Asia
        case "af", "am", "az", "bh", "bd", "bt", "bn", "kh", "cn", "cy", "ge", "in", "id", "ir", "iq", "il", "jp", "jo", "kz", "kw", "kg", "la", "lb", "my", "mv", "mn", "mm", "np", "kp", "om", "pk", "ps", "ph", "qa", "sa", "sg", "kr", "lk", "sy", "tw", "tj", "th", "tl", "tr", "tm", "ae", "uz", "vn", "ye":
            return .asia
            
        // Europe
        case "al", "ad", "at", "by", "be", "ba", "bg", "hr", "cz", "dk", "ee", "fi", "fr", "de", "gr", "hu", "is", "ie", "it", "xk", "lv", "li", "lt", "lu", "mk", "mt", "md", "mc", "me", "nl", "no", "pl", "pt", "ro", "ru", "sm", "rs", "sk", "si", "es", "se", "ch", "ua", "gb", "va":
            return .europe
            
        // North America
        case "ag", "bs", "bb", "bz", "ca", "cr", "cu", "dm", "do", "sv", "gd", "gt", "ht", "hn", "jm", "mx", "ni", "pa", "kn", "lc", "vc", "tt", "us":
            return .northAmerica
            
        // South America
        case "ar", "bo", "br", "cl", "co", "ec", "gy", "py", "pe", "sr", "uy", "ve":
            return .southAmerica
            
        // Oceania
        case "au", "fj", "ki", "mh", "fm", "nr", "nz", "pw", "pg", "ws", "sb", "to", "tv", "vu":
            return .oceania
            
        default:
            // Default to Asia for any unmatched countries
            return .asia
        }
    }
}

// MARK: Extensions for Map
extension Country {
    func getCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func getMapCameraPosition() -> MapCameraPosition {
        return .region(.init(center: self.getCoordinate(), latitudinalMeters: 3000000, longitudinalMeters: 3000000))
    }
}

// MARK: Extensions for CJS
extension Country {
    private func co2Component(minLog: Double, rangeLog: Double) -> Double {
        let raw = log10(territorialMtCO2 + 1)
        guard rangeLog > 0 else { return 0 }
        return 1.0 - (raw - minLog) / rangeLog
    }
    
    private var ndGainComponent: Double { 1.0 - (NDGainScore / 100.0) }
    
    func getClimaJusticeScore(minLog: Double, rangeLog: Double) -> Double {
        let c = co2Component(minLog: minLog, rangeLog: rangeLog)
        let g = ndGainComponent
        let score = (c + g) == 0 ? 0 : 2 * c * g / (c + g)
        return score * 100
    }
    
    func getColorForClimaJusticeScore(_ score: Double) -> Color {
        // Normalise score to 0-1 range
        let normalisedScore = max(0, min(100, score)) / 100.0
        
        if normalisedScore <= 0.5 {
            // Red to Yellow gradient for scores 0-50
            let factor = normalisedScore * 2 // 0 to 1
            return Color(red: 1.0, green: factor, blue: 0.0)
        } else {
            // Yellow to Green gradient for scores 50-100
            let factor = (normalisedScore - 0.5) * 2 // 0 to 1
            return Color(red: 1.0 - factor, green: 1.0, blue: 0.0)
        }
    }

    func getScaleFactor(for score: Double, minScale: Double = 0.5, maxScale: Double = 3.0) -> Double {
        let normalisedScore = max(0, min(100, score)) / 100.0
        return maxScale - (normalisedScore * (maxScale - minScale))
    }
}

// MARK: Extensions for Array
extension Array where Element == Country {
    func logCO2Scaling() -> (min: Double, range: Double) {
        let logs = self.map { log10($0.territorialMtCO2 + 1) }
        guard let min = logs.min(), let max = logs.max() else { return (0, 1) }
        return (min, max - min)
    }
    
    func getFilteredAndSortedCountries(countryDataManager: CountryDataManager, searchText: String, sortingOption: CountrySortOption) -> [Country] {
        let filteredCountriesWithSearchText = self.filter { $0.name.lowercased().replacingOccurrences(of: "ü", with: "u").hasPrefix(searchText.lowercased().replacingOccurrences(of: "ü", with: "u")) }
        
        switch sortingOption {
        case .nameAtoZ:
            return filteredCountriesWithSearchText.sorted { $0.name < $1.name }
        case .nameZtoA:
            return filteredCountriesWithSearchText.sorted { $0.name > $1.name }
        case .climaJusticeScoreHighToLow:
            let (minLog, rangeLog) = countryDataManager.countries.logCO2Scaling()
            return filteredCountriesWithSearchText.sorted { $0.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog) > $1.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog) }
        case .climaJusticeScoreLowToHigh:
            let (minLog, rangeLog) = countryDataManager.countries.logCO2Scaling()
            return filteredCountriesWithSearchText.sorted { $0.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog) < $1.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog) }
        case .ndGainScoreHighToLow:
            return filteredCountriesWithSearchText.sorted { $0.NDGainScore > $1.NDGainScore }
        case .ndGainScoreLowToHigh:
            return filteredCountriesWithSearchText.sorted { $0.NDGainScore < $1.NDGainScore }
        case .territorialMtCO2HighToLow:
            return filteredCountriesWithSearchText.sorted { $0.territorialMtCO2 > $1.territorialMtCO2 }
        case .territorialMtCO2LowToHigh:
            return filteredCountriesWithSearchText.sorted { $0.territorialMtCO2 < $1.territorialMtCO2 }
        }
    }
}
