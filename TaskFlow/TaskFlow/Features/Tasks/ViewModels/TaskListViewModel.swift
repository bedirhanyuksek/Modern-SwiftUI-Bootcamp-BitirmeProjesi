//
//  TaskListViewModel.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import Foundation

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let repository: TaskRepository
    private let appState: AppState
    
    init(repository: TaskRepository, appState: AppState){
        self.repository = repository
        self.appState = appState
    }
    
    func loadTasks() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let allTasks = try await repository.fetchTasks(for: appState.session)
            guard let currentUser = appState.session else {
                tasks = []
                return
            }
            
            
            if currentUser.role == .admin {
                
                tasks = allTasks
            } else {
                let filteredTasks = allTasks.filter { task in
                    let isAssigned = task.isAssigned(to: currentUser)
                    if !isAssigned {
                    }
                    return isAssigned
                }
                tasks = filteredTasks

            }
            
            let tasksWithoutAssignment = allTasks.filter { $0.assignedTo == nil || $0.assignedTo?.isEmpty == true }
            if !tasksWithoutAssignment.isEmpty {
            }
        } catch {
            let errorMsg = "Görevler Yüklenemedi: \(error.localizedDescription)"
            errorMessage = errorMsg
        }
    }
    
    func deleteTask(id: UUID) async {
        do {
            try await repository.deleteTask(id: id)
            await loadTasks()
        } catch {
            errorMessage = "Görev silinemedi."
        }
    }
}
