//
//  Region.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-25.
//

import Foundation

enum Region: String, Identifiable, CaseIterable {
    case africa = "Africa"
    case asia = "Asia"
    case europe = "Europe"
    case northAmerica = "North America"
    case southAmerica = "South America"
    case oceania = "Oceania"

    var id: Self { self }
}
