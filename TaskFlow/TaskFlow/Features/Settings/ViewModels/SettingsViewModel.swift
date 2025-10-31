//
//  SettingsViewModel.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil
    @Published var isSigningOut = false
    
    private let appState: AppState
    private let authRepository: AuthRepository
    
    init(appState: AppState, authRepository: AuthRepository? = nil) {
        self.appState = appState
        self.authRepository = authRepository ?? FirebaseAuthRepository()
    }
    
    func signOut() async {
        isSigningOut = true
        defer { isSigningOut = false }
        
        do {
            try await authRepository.signOut()
            appState.session = nil
        } catch {
            print("Çıkış hatası: \(error.localizedDescription)")
        }
    }
}

