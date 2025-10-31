//
//  TaskRepository.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import Foundation

protocol TaskRepository {
    func fetchTasks(for user: UserSession?) async throws -> [TaskModel]
    func createTask(_ tasks: TaskModel) async throws
    func deleteTask(id: UUID) async throws
    func updateTaskStatus(_ taskId: UUID, status: TaskStatus) async throws
}
