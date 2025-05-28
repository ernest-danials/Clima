//
//  LicenseView.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-26.
//

import SwiftUI

struct LicensesView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                NavigationLink {
                    ScrollView {
                        VStack {
                            Link(destination: URL(string: "https://github.com/eesur/country-codes-lat-long")!) {
                                buttonLabel(title: "View on GitHub", imageName: "doc.text.fill", color: .blue)
                            }
                            .scaleButtonStyle()
                            .padding(.bottom)
                            
                            Text("""
                        MIT License
                        
                        Copyright (c) 2022 Sundar Singh
                        
                        Permission is hereby granted, free of charge, to any person obtaining a copy
                        of this software and associated documentation files (the "Software"), to deal
                        in the Software without restriction, including without limitation the rights
                        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
                        copies of the Software, and to permit persons to whom the Software is
                        furnished to do so, subject to the following conditions:
                        
                        The above copyright notice and this permission notice shall be included in all
                        copies or substantial portions of the Software.
                        
                        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
                        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
                        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
                        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
                        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
                        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
                        SOFTWARE.
                        """
                            ).customFont(size: 20, design: .monospaced)
                        }
                        .safeAreaPadding([.horizontal, .bottom], 25)
                    }
                    .prioritiseScaleButtonStyle()
                    .navigationTitle("country-codes-lat-long")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { dismiss() }.fontWeight(.medium)
                        }
                    }
                } label: {
                    buttonLabel(title: "country-codes-lat-long", imageName: "globe.americas.fill", color: .blue, showArrow: false)
                }.scaleButtonStyle()
            }
            .prioritiseScaleButtonStyle()
            .safeAreaPadding([.horizontal, .bottom], 25)
            .navigationTitle("Licenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.medium)
                }
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
            
            if !showArrow {
                Image(systemName: "chevron.right")
                    .fontWeight(.medium)
                    .foregroundStyle(color.secondary)
            } else {
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
    LicensesView()
}
