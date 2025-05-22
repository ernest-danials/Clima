//
//  HomeView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI
import MapKit

struct HomeView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Map {
                MapCircle(center: .init(latitude: 56.1304, longitude: -106.3468), radius: 1000000)
                    .mapOverlayLevel(level: .aboveLabels)
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .safeAreaPadding(20)
        }
    }
}

#Preview {
    HomeView()
}
