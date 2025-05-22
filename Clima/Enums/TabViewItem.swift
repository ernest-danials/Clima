//
//  TabViewItem.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import Foundation

enum TabViewItem: String, Identifiable, CaseIterable {
    case home = "Home"
    case graphs = "Graphs"
    case settings = "Settings"
    
    var id: Self { self }
    
    var imageName: String {
        switch self {
        case .home:
            return "house"
        case .graphs:
            return "chart.xyaxis.line"
        case .settings:
            return "gearshape"
        }
    }
}
