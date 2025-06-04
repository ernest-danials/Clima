//
//  ResourcesView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-26.
//

import SwiftUI

struct ResourcesView: View {
    @EnvironmentObject var onboardingPresentationManager: OnboardingPresentationManager
    
    @State private var isShowingLicensesView: Bool = false
    @State private var selectedDataTypeForInterpretationInfo: DataType? = nil
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView {
                    VStack {
                        Image(.appIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        Text("Clima")
                            .customFont(size: 28, weight: .heavy)
                        
                        Text("Explore global climate justice")
                            .customFont(size: 18, weight: .medium)
                            .foregroundStyle(.secondary)
                        
                        Text("Version " + "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"))")
                            .customFont(size: 15, weight: .regular)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            self.onboardingPresentationManager.showOnboardingIfNecessary(overriding: true)
                        } label: {
                            Label("Show Onboarding", systemImage: "eyes")
                                .customFont(size: 18, weight: .medium)
                                .padding()
                                .background(Material.ultraThin)
                                .cornerRadius(15, corners: .allCorners)
                        }
                        .scaleButtonStyle()
                        .padding(.top)
                    }
                    
                    Divider().padding()
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: geo.size.width / 2, maximum: geo.size.width / 1.5)), count: 2), spacing: 25) {
                        VStack {
                            Text("Clima is an open source project")
                                .customFont(size: 23, weight: .bold)
                            
                            Text("This project is open source under MIT license.")
                                .customFont(size: 16)
                                .foregroundStyle(.secondary)
                            
                            Link(destination: URL(string: "https://github.com/ernest-danials/Clima")!) {
                                buttonLabel(title: "View Source Code on GitHub", imageName: "book.pages.fill", color: .blue)
                            }.scaleButtonStyle()
                        }
                        .alignViewVertically(to: .top)
                        .padding(25)
                        .background(Material.ultraThin)
                        .cornerRadius(20, corners: .allCorners)
                        .alignViewVertically(to: .top)
                        
                        VStack {
                            Text("Check Our Sources")
                                .customFont(size: 23, weight: .bold)
                            
                            Text("Clima uses the data of 2022 from the following sources.")
                                .customFont(size: 16)
                                .foregroundStyle(.secondary)
                            
                            Link(destination: URL(string: "https://globalcarbonatlas.org/emissions/carbon-emissions/")!) {
                                buttonLabel(title: "Global Carbon Atlas (2022)", imageName: "carbon.dioxide.cloud.fill", color: .yellow)
                            }.scaleButtonStyle()
                            
                            Link(destination: URL(string: "https://gain.nd.edu/our-work/country-index/")!) {
                                buttonLabel(title: "ND-GAIN Country Index (2022)", imageName: "shield.lefthalf.filled", color: .green)
                            }.scaleButtonStyle()
                        }
                        .alignViewVertically(to: .top)
                        .padding(25)
                        .background(Material.ultraThin)
                        .cornerRadius(20, corners: .allCorners)
                        .alignViewVertically(to: .top)
                        
                        VStack {
                            Text("What Does the Data Mean?")
                                .customFont(size: 23, weight: .bold)
                            
                            Text("The followings are how we process and interpret the data.")
                                .customFont(size: 16)
                                .foregroundStyle(.secondary)
                            
                            ForEach(DataType.allCases) { type in
                                Button {
                                    self.selectedDataTypeForInterpretationInfo = type
                                } label: {
                                    buttonLabel(title: type.rawValue, imageName: type.imageName, color: type.color, showArrow: false)
                                }.scaleButtonStyle()
                            }
                        }
                        .alignViewVertically(to: .top)
                        .padding(25)
                        .background(Material.ultraThin)
                        .cornerRadius(20, corners: .allCorners)
                        .alignViewVertically(to: .top)
                        
                        VStack {
                            Text("Our Websites")
                                .customFont(size: 23, weight: .bold)
                            
                            Link(destination: URL(string: "https://myungjoon.com/clima")!) {
                                buttonLabel(title: "Our Homepage", imageName: "globe", color: .blue)
                            }.scaleButtonStyle()
                            
                            Link(destination: URL(string: "https://myungjoon.com")!) {
                                buttonLabel(title: "Our Developer's Website", imageName: "globe", color: .blue)
                            }.scaleButtonStyle()
                        }
                        .alignViewVertically(to: .top)
                        .padding(25)
                        .background(Material.ultraThin)
                        .cornerRadius(20, corners: .allCorners)
                        
                        VStack {
                            Text("Legal")
                                .customFont(size: 23, weight: .bold)

                            Button {
                                self.isShowingLicensesView = true
                            } label: {
                                buttonLabel(title: "Licenses", imageName: "text.document.fill", color: .blue, showArrow: false)
                            }.scaleButtonStyle()
                            
                            Link(destination: URL(string: "https://myungjoon.com/clima/privacy")!) {
                                buttonLabel(title: "Privacy Policy", imageName: "hand.raised.fill", color: .blue)
                            }.scaleButtonStyle()
                            
                            Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                                buttonLabel(title: "Terms of Service", imageName: "text.document.fill", color: .blue)
                            }.scaleButtonStyle()
                            
                            Text("Copyright © 2025 Clima by Myung Joon Kang. All rights reserved.")
                                .customFont(size: 15)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                        }
                        .alignViewVertically(to: .top)
                        .padding(25)
                        .background(Material.ultraThin)
                        .cornerRadius(20, corners: .allCorners)
                        .alignViewVertically(to: .top)
                    }
                    .safeAreaPadding(.horizontal)
                }
                .prioritiseScaleButtonStyle()
                .navigationTitle("Resources")
            }
            .sheet(isPresented: $isShowingLicensesView) {
                LicensesView()
            }
            .sheet(item: $selectedDataTypeForInterpretationInfo) { type in
                DataInterpretationView(type)
            }
        }
    }
    
    private func buttonLabel(title: String, imageName: String, color: Color, showArrow: Bool = true, tintText: Bool = false) -> some View {
        HStack {
            Image(systemName: imageName)
                .foregroundStyle(color)
                .frame(width: 22)
            
            if tintText {
                Text(title)
                    .customFont(size: 17, weight: .medium)
                    .foregroundStyle(color)
            } else {
                Text(title)
                    .customFont(size: 17, weight: .medium)
            }
            
            Spacer()
            
            if showArrow {
                Image(systemName: "arrow.up.right")
                    .fontWeight(.medium)
                    .foregroundStyle(color.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(18)
    }
}

#Preview {
    ResourcesView()
        .environmentObject(OnboardingPresentationManager())
}
