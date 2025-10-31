//
//  LoginViewModel.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 27.10.2025.
//

import Foundation
@MainActor

final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var error: String?
    @Published var isLoading: Bool = false
    
    public let auth: AuthRepository
    private let appState: AppState
    
    init(auth: AuthRepository, appState: AppState) {
        self.auth = auth
        self.appState = appState
    }
    
    func signIn() async {
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let session = try await auth.signIn(email: email, password: password)
            appState.session = session
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
