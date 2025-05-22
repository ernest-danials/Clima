//
//  Country.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import Foundation

struct Country: Identifiable, Decodable {
    let id: String
    let name: String
    let territorialMtCO2: Double
    let NDGainScore: Double
}
