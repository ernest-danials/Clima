//
//  ChartsView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-24.
//

import SwiftUI

struct ChartsView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    var body: some View {
        NavigationStack {
            ScrollView {
                
            }
            .prioritiseScaleButtonStyle()
            .navigationTitle("Charts")
        }
    }
}

#Preview {
    ChartsView()
        .environmentObject(CountryDataManager())
}
