//
//  MockTaskRepository.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import Foundation

@MainActor
final class MockTaskRepository: TaskRepository, ObservableObject {
    @Published private(set) var tasks: [TaskModel] = []
    
    func fetchTasks() async throws -> [TaskModel] {
        return tasks
    }
    
    func createTask(_ task: TaskModel) async throws {
        tasks.append(task)
    }
    
    func deleteTask(id: UUID) async throws {
        tasks.removeAll { $0.id == id }
    }
    
    func updateTaskStatus(_ taskId: UUID, status: TaskStatus) async throws {
        guard let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[index].status = status
    }
    
    func taskShow(for user: UserSession) -> [TaskModel] {
        user.role == .admin ? tasks : tasks.filter { $0.isAssigned(to: user) }
    }
    
}
