//
//  CountryDataManager.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import Foundation

final class CountryDataManager: ObservableObject {
    @Published var countries: [Country] = []
    
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
        } catch {
            print("Error decoding JSON data: \(error)")
        }
    }
}
