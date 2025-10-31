//
//  HomeViewModel.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var totalTasks: Int = 0
    @Published var pendingTasks: Int = 0
    @Published var completedTasks: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let repository: TaskRepository
    private let appState: AppState
    
    init(repository: TaskRepository, appState: AppState) {
        self.repository = repository
        self.appState = appState
    }
    
    func loadStatistics() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            var allTasks = try await repository.fetchTasks()
            
            // Kullanıcıya göre filtreleme
            if let currentUser = appState.session {
                if currentUser.role != .admin {
                    allTasks = allTasks.filter { $0.isAssigned(to: currentUser) }
                }
            }
            
            totalTasks = allTasks.count
            pendingTasks = allTasks.filter { $0.status != .done }.count
            completedTasks = allTasks.filter { $0.status == .done }.count
        } catch {
            errorMessage = "İstatistikler yüklenemedi: \(error.localizedDescription)"
        }
    }
}
