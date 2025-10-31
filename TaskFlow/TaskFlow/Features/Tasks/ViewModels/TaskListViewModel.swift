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
            let allTasks = try await repository.fetchTasks()
            print("📋 Tüm görevler yüklendi: \(allTasks.count) adet")
            
            // Kullanıcıya göre filtreleme
            guard let currentUser = appState.session else {
                print("⚠️ Kullanıcı oturumu bulunamadı")
                tasks = []
                return
            }
            
            print("👤 Mevcut kullanıcı: \(currentUser.email) (\(currentUser.role.rawValue)) - UID: \(currentUser.uid)")
            
            if currentUser.role == .admin {
                // Admin tüm görevleri görür
                tasks = allTasks
                print("✅ Admin - Tüm \(tasks.count) görev gösteriliyor")
            } else {
                // Staff sadece kendisine atanan görevleri görür
                let filteredTasks = allTasks.filter { task in
                    let isAssigned = task.isAssigned(to: currentUser)
                    if !isAssigned {
                        print("⏭️ Görev atlanıyor: '\(task.title)' - assignedTo: \(task.assignedTo ?? "nil"), kullanıcı UID/email: \(currentUser.uid)/\(currentUser.email)")
                    }
                    return isAssigned
                }
                tasks = filteredTasks
                print("✅ Staff - \(tasks.count)/\(allTasks.count) görev gösteriliyor (kendisine atanan)")
            }
            
            // Boş assignedTo durumlarını logla
            let tasksWithoutAssignment = allTasks.filter { $0.assignedTo == nil || $0.assignedTo?.isEmpty == true }
            if !tasksWithoutAssignment.isEmpty {
                print("⚠️ UYARI: \(tasksWithoutAssignment.count) görev atanmamış durumda")
            }
        } catch {
            let errorMsg = "Görevler Yüklenemedi: \(error.localizedDescription)"
            errorMessage = errorMsg
            print("❌ HATA: \(errorMsg)")
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
