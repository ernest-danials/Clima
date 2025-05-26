//
//  CompareView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-25.
//

import SwiftUI

struct CompareView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    var body: some View {
        NavigationStack {
            ScrollView {
                
            }
            .prioritiseScaleButtonStyle()
            .navigationTitle("Compare")
        }
    }
}

#Preview {
    CompareView()
        .environmentObject(CountryDataManager())
}
