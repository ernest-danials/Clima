//
//  OnboardingPresentationManager.swift
//  Clima
//
//  Created by Myung Joon Kang on 2025-05-31.
//

import SwiftUI

final class OnboardingPresentationManager: ObservableObject {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @Published var isShowingOnboarding: Bool = false
    
    func showOnboardingIfNecessary(overriding: Bool = false) {
        if !hasSeenOnboarding || overriding {
            withAnimation {
                self.isShowingOnboarding = true
            }
        }
    }

    func dismissOnboarding() {
        withAnimation {
            self.isShowingOnboarding = false
            self.hasSeenOnboarding = true
        }
    }
}
