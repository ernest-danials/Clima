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
    
    private var ndGainComponent: Double { NDGainScore / 100.0 }
    
    func getClimaJusticeScore(minLog: Double, rangeLog: Double) -> Double {
        let c = co2Component(minLog: minLog, rangeLog: rangeLog)
        let g = ndGainComponent
        let score = (c + g) == 0 ? 0 : 2 * c * g / (c + g)
        return score * 100
    }
}

extension Array where Element == Country {
    func logCO2Scaling() -> (min: Double, range: Double) {
        let logs = self.map { log10($0.territorialMtCO2 + 1) }
        guard let min = logs.min(), let max = logs.max() else { return (0, 1) }
        return (min, max - min)
    }
}
