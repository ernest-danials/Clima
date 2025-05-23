//
//  Country.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import Foundation
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
    func getCoordinate() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
