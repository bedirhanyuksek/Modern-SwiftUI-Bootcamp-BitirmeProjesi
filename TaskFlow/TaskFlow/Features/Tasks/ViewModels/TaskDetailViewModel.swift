//
//  TaskDetailViewModel.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import Foundation

@MainActor
final class TaskDetailViewModel: ObservableObject {
    @Published var task: TaskModel
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isUpdatingStatus = false
    
    private let repository: TaskRepository
    private let appState: AppState
    
    init(task: TaskModel, repository: TaskRepository, appState: AppState) {
        self.task = task
        self.repository = repository
        self.appState = appState
    }
    
    var canUpdateStatus: Bool {
        guard let currentUser = appState.session else { return false }
        return currentUser.role == .admin || task.isAssigned(to: currentUser)
    }
    
    var nextStatus: TaskStatus? {
        switch task.status {
        case .planned: return .todo
        case .todo: return .inProgress
        case .inProgress: return .control
        case .control: return .done
        case .done: return nil
        }
    }
    
    func updateStatus() async {
        guard let next = nextStatus else { return }
        
        isUpdatingStatus = true
        defer { isUpdatingStatus = false }
        
        do {
            try await repository.updateTaskStatus(task.id, status: next)
            task.status = next
            errorMessage = nil
        } catch {
            errorMessage = "Durum güncellenemedi: \(error.localizedDescription)"
        }
    }
    
    func statusText(_ status: TaskStatus) -> String {
        switch status {
        case .planned: return "Planlandı"
        case .todo: return "Yapılacak"
        case .inProgress: return "Çalışmada"
        case .control: return "Kontrol"
        case .done: return "Tamamlandı"
        }
    }
}
