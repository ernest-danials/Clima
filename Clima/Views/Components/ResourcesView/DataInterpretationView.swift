//
//  DataInterpretationView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-26.
//

import SwiftUI

struct DataInterpretationView: View {
    @Environment(\.dismiss) var dismiss
    
    let dataType: DataType
    let isForOnboarding: Bool
    
    init(_ dataType: DataType, isForOnboarding: Bool = false) {
        self.dataType = dataType
        self.isForOnboarding = isForOnboarding
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with icon and title
                    HStack {
                        Image(systemName: dataType.imageName)
                            .font(.largeTitle)
                            .foregroundColor(dataType.color)
                        
                        VStack(alignment: .leading) {
                            Text(dataType.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(getSubtitle())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Content sections
                    VStack(alignment: .leading, spacing: 20) {
                        // What is it section
                        SectionView(title: "What is it?", content: getWhatIsItContent())
                        
                        // How is it calculated section
                        SectionView(title: "How is it calculated?", content: getCalculationContent())
                        
                        // How to interpret section
                        SectionView(title: "How to interpret it?", content: getInterpretationContent())
                        
                        // Additional context section
                        if !getAdditionalContext().isEmpty {
                            SectionView(title: "Additional Context", content: getAdditionalContext())
                        }
                    }
                }
                .safeAreaPadding(25)
            }
            .navigationTitle("What is " + dataType.rawValue + "?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .toolbar(self.isForOnboarding ? .hidden : .visible)
        }
    }
    
    private func getSubtitle() -> String {
        switch dataType {
        case .climaJusticeScore:
            return "A composite measure of climate vulnerability and responsibility"
        case .territorialMtCO2:
            return "Annual carbon dioxide emissions within national borders"
        case .ndGainScore:
            return "Readiness and vulnerability to climate change adaptation"
        }
    }
    
    private func getWhatIsItContent() -> String {
        switch dataType {
        case .climaJusticeScore:
            return "The Clima Justice Score is a composite metric that combines a country's climate vulnerability (measured by the ND-Gain Score) with its carbon emissions responsibility (measured by Territorial MtCO2). It aims to highlight the climate justice paradox where countries most vulnerable to climate change often contribute least to the problem."
            
        case .territorialMtCO2:
            return "Territorial MtCO2 represents the total amount of carbon dioxide emissions produced within a country's borders in a given year (2022), measured in megatonnes (million tonnes). Clima uses data from [Global Carbon Atlas](https://globalcarbonatlas.org)"
            
        case .ndGainScore:
            return "The ND-Gain Score ([Notre Dame Global Adaptation Initiative](https://gain.nd.edu/)) measures a country's vulnerability to climate change and its readiness to improve resilience. It combines 45 indicators across six life-supporting sectors: food, water, health, ecosystem services, human habitat, and infrastructure. Clima uses data from 2022."
        }
    }
    
    private func getCalculationContent() -> String {
        switch dataType {
        case .climaJusticeScore:
            return """
            The Clima Justice Score (CJS) uses the harmonic mean formula:
            
            CJS = 2 × C × G / (C + G) × 100
            
            Where:
            • C = CO2 Component: Normalised inverse of log(territorial emissions + 1)
            • G = Gain Component: Inverted ND-Gain Score (1 - ND-Gain Score / 100)
            
            The CO2 component is calculated as:
            C = 1 - (log₁₀(emissions + 1) - min_log) / range_log
            
            This formula ensures that countries with low emissions and high vulnerability (low ND-GAIN) receive higher scores, whilst those with high emissions and strong readiness (high ND-GAIN) receive lower scores.
            """
            
        case .territorialMtCO2:
            return """
            Territorial emissions are calculated by summing all CO2 emissions from sources within a country's borders:
            
            • Fossil fuel combustion (coal, oil, gas)
            • Industrial processes (cement, steel production)
            • Land use changes (deforestation, agriculture)
            • Waste management
            • Transportation (domestic flights, road transport)
            """
            
        case .ndGainScore:
            return """
            The ND-Gain Score is calculated using 45 indicators across two main dimensions:
            
            Vulnerability (36 indicators):
            • Exposure to climate hazards
            • Sensitivity to climate impacts
            • Adaptive capacity
            
            Readiness (9 indicators):
            • Economic readiness
            • Governance readiness
            • Social readiness
            
            Each indicator is normalised to a 0-1 scale, then combined using equal weights. The final score ranges from 0 (most vulnerable/least ready) to 100 (least vulnerable/most ready).
            """
        }
    }
    
    private func getInterpretationContent() -> String {
        switch dataType {
        case .climaJusticeScore:
            return """
            Higher scores (closer to 100) indicate greater climate justice concerns:
            
            • 80-100: Countries with very high vulnerability and very low emissions
            • 60-79: High vulnerability with low to moderate emissions
            • 40-59: Moderate vulnerability and emissions balance
            • 20-39: Lower vulnerability with moderate to high emissions
            • 0-19: Low vulnerability with very high emissions
            
            Countries with higher scores often require more international climate support, whilst those with lower scores bear greater responsibility for emissions reduction.
            """
            
        case .territorialMtCO2:
            return """
            Emissions levels can be interpreted in context:
            
            • >1000 MtCO2: Major emitters (China, USA, India)
            • 100-1000 MtCO2: Significant emitters (most developed countries)
            • 10-100 MtCO2: Moderate emitters (smaller developed/emerging economies)
            • 1-10 MtCO2: Low emitters (small countries, island states)
            • <1 MtCO2: Minimal emitters (least developed countries)
            """
            
        case .ndGainScore:
            return """
            ND-Gain Scores indicate climate adaptation capacity:
            
            • 70-100: High readiness, low vulnerability (most developed countries)
            • 50-69: Moderate readiness and vulnerability (emerging economies)
            • 30-49: Lower readiness, higher vulnerability (developing countries)
            • 0-29: Low readiness, high vulnerability (least developed countries)
            
            Higher scores indicate better capacity to adapt to climate change, whilst lower scores suggest greater need for international adaptation support and financing.
            """
        }
    }
    
    private func getAdditionalContext() -> String {
        switch dataType {
        case .climaJusticeScore:
            return """
            The Clima Justice Score highlights the fundamental inequity in climate change: those who contribute least to the problem often suffer most from its impacts. This metric can inform:
            
            • Climate finance allocation
            • International adaptation funding priorities
            • Loss and damage compensation discussions
            • Technology transfer programmes
            
            It's important to note that this is one of many ways to measure climate justice, and should be considered alongside other factors such as historical emissions, per capita emissions, and development needs.
            """
            
        case .territorialMtCO2:
            return """
            Territorial emissions are just one way to measure a country's carbon footprint. Other important metrics include:
            
            • Consumption-based emissions (including imports)
            • Per capita emissions (accounting for population)
            • Historical cumulative emissions
            • Emissions intensity (per unit of GDP)
            """
            
        case .ndGainScore:
            return """
            The ND-Gain Score is updated annually and provides a comprehensive view of climate adaptation needs. However, it should be complemented with:
            
            • Local vulnerability assessments
            • Sector-specific adaptation needs
            • Indigenous and traditional knowledge
            • Gender and social equity considerations
            
            The score helps identify countries that may need priority support for climate adaptation, but local context and community needs should always inform specific adaptation strategies.
            """
        }
    }
}

struct SectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(.init(content))
                .font(.body)
                .lineSpacing(4)
        }
    }
}

#Preview {
    DataInterpretationView(.climaJusticeScore)
}
