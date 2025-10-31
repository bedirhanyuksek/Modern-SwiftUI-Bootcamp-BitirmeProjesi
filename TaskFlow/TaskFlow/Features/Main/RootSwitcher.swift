//
//  RootSwitcher.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 27.10.2025.
//

import SwiftUI

struct RootSwitcher: View {
    @EnvironmentObject var appState: AppState
    
    @StateObject private var authRepo = FirebaseAuthRepository()
    @StateObject private var taskRepo = FirebaseTaskRepository()
    
    
    var body: some View {
        NavigationStack {
            if let session = appState.session {
                MainTabView(repository: taskRepo)
                    .environmentObject(appState)
            } else {
                LoginView(viewModel: LoginViewModel(auth: authRepo, appState: appState))
                    .environmentObject(appState)
            }
        }
    }
}
