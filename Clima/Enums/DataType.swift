//
//  DataType.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-26.
//

import SwiftUI

enum DataType: String, Identifiable, CaseIterable {
    case climaJusticeScore = "Clima Justice Score"
    case territorialMtCO2 = "Territorial MtCO2"
    case ndGainScore = "ND-Gain Score"
    
    var imageName: String {
        switch self {
        case .climaJusticeScore:
            return "scale.3d"
        case .territorialMtCO2:
            return "carbon.dioxide.cloud.fill"
        case .ndGainScore:
            return "shield.lefthalf.filled"
        }
    }
    
    var color: Color {
        switch self {
        case .climaJusticeScore:
            return .orange
        case .territorialMtCO2:
            return .yellow
        case .ndGainScore:
            return .green
        }
    }
    
    var id: Self { self }
}
