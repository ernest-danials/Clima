//
//  CardCell.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI

struct CountryCard: View {
    let country: Country
    
    init(_ country: Country) {
        self.country = country
    }
    
    var body: some View {
        HStack(spacing: 13) {
            AsyncImage(url: URL(string: "https://cdn.ipregistry.co/flags/wikimedia/\(country.id).png")!) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60)
            .cornerRadius(5, corners: .allCorners)
            
            VStack(alignment: .leading) {
                Text(country.name)
                    .customFont(size: 17, weight: .bold)
                    .multilineTextAlignment(.leading)
            }
        }
        .alignView(to: .leading)
        .padding()
        .background(Material.ultraThin)
        .cornerRadius(15, corners: .allCorners)
    }
}

#Preview {
    CountryCard(.init(id: "us", name: "United States", latitude: 0, longitude: 0, territorialMtCO2: 100, NDGainScore: 100))
}
