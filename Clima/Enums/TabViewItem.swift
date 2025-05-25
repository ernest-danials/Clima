//
//  TabViewItem.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import Foundation

enum TabViewItem: String, Identifiable, CaseIterable {
    case map = "Map"
    case charts = "Charts"
    case compare = "Compare"
    case settings = "Settings"
    
    var id: Self { self }
    
    var imageName: String {
        switch self {
        case .map:
            return "map"
        case .charts:
            return "chart.xyaxis.line"
        case .compare:
            return "arrow.left.arrow.right"
        case .settings:
            return "gearshape"
        }
    }
}
