//
//  DeviceRotationHelper.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-26.
//

import SwiftUI

@available(*, deprecated, message: "Blocking MapView when in portrait has been removed.")
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
    @available(*, deprecated, message: "Blocking MapView when in portrait has been removed.")
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationHelperViewModifier(action: action))
    }
}
