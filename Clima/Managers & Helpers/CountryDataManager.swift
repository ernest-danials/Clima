//
//  CountryDataManager.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import Foundation

final class CountryDataManager: ObservableObject {
    @Published var countries: [Country] = []

    // Pre-computed once at load — data never changes after init
    private(set) var logCO2Scale: (min: Double, range: Double) = (0, 1)
    private(set) var countriesSortedByClimaJusticeScore: [Country] = []

    required init() {
        loadData()
    }

    func loadData() {
        let decoder = JSONDecoder()

        do {
            guard let countriesPath = Bundle.main.url(forResource: "clima_countries_data", withExtension: "json") else {
                print("Error: Cannot find JSON files in bundle")
                return
            }
            let countriesData = try Data(contentsOf: countriesPath)

            self.countries = try decoder.decode([Country].self, from: countriesData)

            logCO2Scale = self.countries.logCO2Scaling()
            countriesSortedByClimaJusticeScore = self.countries.sorted {
                $0.getClimaJusticeScore(minLog: logCO2Scale.min, rangeLog: logCO2Scale.range) >
                $1.getClimaJusticeScore(minLog: logCO2Scale.min, rangeLog: logCO2Scale.range)
            }
        } catch {
            print("Error decoding JSON data: \(error)")
        }
    }

    func getCountryClimaJusticeScoreRank(for country: Country) -> Int {
        guard let index = countriesSortedByClimaJusticeScore.firstIndex(of: country) else {
            return 0
        }
        return index + 1
    }
}
