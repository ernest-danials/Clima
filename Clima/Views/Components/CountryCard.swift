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
            Image(country.id)
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .cornerRadius(5, corners: .allCorners)
            
            VStack(alignment: .leading) {
                Text(country.name)
                    .customFont(size: 17, weight: .bold)
                    .multilineTextAlignment(.leading)
                
                Text("\(country.territorialMtCO2)")
                    .foregroundStyle(.secondary)
                
                Text("\(country.NDGainScore)")
                    .foregroundStyle(.secondary)
            }
        }
        .alignView(to: .leading)
        .padding()
        .background(Material.ultraThin)
        .cornerRadius(15, corners: .allCorners)
    }
}
