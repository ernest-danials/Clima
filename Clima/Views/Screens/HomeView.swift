//
//  HomeView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    
    @State private var selectedCountry: Country? = nil
    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var searchText: String = ""
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .trailing) {
                Map(position: $mapCameraPosition) {
                    ForEach(countryDataManager.countries) { country in
                        MapCircle(center: country.getCoordinate(), radius: 500000)
                            .foregroundStyle(.red.opacity(0.3))
                        
                        Annotation(country.name, coordinate: country.getCoordinate()) {}
                    }
                }
                .mapStyle(.imagery(elevation: .realistic))
                
                VStack {
                    HStack {
                        Text("Clima")
                            .customFont(size: 30, weight: .heavy)
                        
                        Spacer()
                        
                        Button {
                            changeSelectedCountry(to: nil)
                            HapticManager.shared.impact(style: .soft)
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                        }
                        .scaleButtonStyle(scaleAmount: 0.97)
                    }
                    
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(countryDataManager.countries) { country in
                                Button {
                                    changeSelectedCountry(to: country)
                                    HapticManager.shared.impact(style: .soft)
                                } label: {
                                    CountryCard(country)
                                }
                                .scaleButtonStyle()
                            }
                        }
                    }
                    .prioritiseScaleButtonStyle()
                }
                .frame(width: geo.size.width / 4, height: geo.size.height)
                .safeAreaPadding(25)
                .background(Material.ultraThin)
                .cornerRadius(20, corners: .allCorners)
            }
        }
        .safeAreaPadding(25)
        .statusBarHidden()
    }
    
    private func changeSelectedCountry(to country: Country?) {
        withAnimation {
            if let country = country {
                self.selectedCountry = country
                self.mapCameraPosition = .region(.init(center: country.getCoordinate(), latitudinalMeters: 3000000, longitudinalMeters: 3000000))
            } else {
                self.mapCameraPosition = .automatic
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CountryDataManager())
}
