//
//  ScaleButtonStyle.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-22.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    let scaleAmount: CGFloat
    let opacityAmount: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .opacity(configuration.isPressed ? opacityAmount : 1.0)
    }
}

extension View {
    func scaleButtonStyle(scaleAmount: CGFloat = 0.98, opacityAmount: Double = 1.0) -> some View {
        self.buttonStyle(ScaleButtonStyle(scaleAmount: scaleAmount, opacityAmount: opacityAmount))
    }
}

extension ScrollView {
    func prioritiseScaleButtonStyle() -> some View {
        self.gesture(DragGesture(minimumDistance: 0), including: .all)
    }
}
