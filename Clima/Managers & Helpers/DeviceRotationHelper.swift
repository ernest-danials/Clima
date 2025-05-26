//
//  DeviceRotationHelper.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-26.
//

import SwiftUI

struct DeviceRotationHelperViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationHelperViewModifier(action: action))
    }
}
