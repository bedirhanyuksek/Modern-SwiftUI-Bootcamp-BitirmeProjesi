//
//  FirebaseTaskRepository.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import Foundation
import FirebaseFirestore

@MainActor
final class FirebaseTaskRepository: TaskRepository, ObservableObject {
    private let db = Firestore.firestore()
    
    @Published private(set) var tasks: [TaskModel] = []
    
    func fetchTasks() async throws -> [TaskModel] {
        let snapshot = try await db.collection("tasks").getDocuments()
        let fetchedTasks = snapshot.documents.compactMap { doc -> TaskModel? in
            let data = doc.data()
            
            guard
                let title = data["title"] as? String,
                let description = data["description"] as? String
            else {
                return nil
            }
            
            let assignedToRaw = data["assignedTo"] as? String
            let assignedEmailRaw = data["assignedEmail"] as? String
            
            let assignedTo: String?
            if let assignedToRaw {
                let trimmed = assignedToRaw.trimmingCharacters(in: .whitespacesAndNewlines)
                assignedTo = trimmed.isEmpty ? nil : trimmed
            } else if let assignedEmailRaw {
                let trimmed = assignedEmailRaw.trimmingCharacters(in: .whitespacesAndNewlines)
                assignedTo = trimmed.isEmpty ? nil : trimmed
            } else {
                assignedTo = nil
            }
            
            let date: Date
            if let ts = data["date"] as? Timestamp {
                date = ts.dateValue()
            } else {
                date = Date()
            }
            
            let statusString = data["status"] as? String ?? TaskStatus.planned.rawValue
            let status = TaskStatus(rawValue: statusString) ?? .planned
            
            let slaDeadline: Date?
            if let slaTs = data["slaDeadline"] as? Timestamp {
                slaDeadline = slaTs.dateValue()
            } else {
                slaDeadline = nil
            }
            
            let id = UUID(uuidString: doc.documentID) ?? UUID()
            
            return TaskModel(
                id: id,
                title: title,
                description: description,
                status: status,
                date: date,
                assignedTo: assignedTo,
                slaDeadline: slaDeadline
            )
        }
        self.tasks = fetchedTasks
        return fetchedTasks
    }
    
    func createTask(_ task: TaskModel) async throws {
        let assignedToValue = task.assignedTo?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        print("📝 Görev oluşturuluyor:")
        print("   - ID: \(task.id.uuidString)")
        print("   - Başlık: \(task.title)")
        print("   - AssignedTo: \(assignedToValue.isEmpty ? "(boş)" : assignedToValue)")
        
        guard !assignedToValue.isEmpty else {
            print("❌ HATA: assignedTo boş, görev oluşturulamıyor")
            throw NSError(domain: "FirebaseTaskRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görev atanacak kullanıcı belirtilmedi."])
        }
        
        var taskData: [String: Any] = [
            "title": task.title,
            "description": task.description,
            "status": task.status.rawValue,
            "date": Timestamp(date: task.date),
            "assignedTo": assignedToValue
        ]
        
        if let slaDeadline = task.slaDeadline {
            taskData["slaDeadline"] = Timestamp(date: slaDeadline)
        }
        
        print("📤 Firestore'a kaydediliyor: \(taskData)")
        
        try await db.collection("tasks").document(task.id.uuidString).setData(taskData)
        
        print("✅ Görev başarıyla oluşturuldu")
    }
    
    func deleteTask(id: UUID) async throws {
        try await db.collection("tasks").document(id.uuidString).delete()
    }
    
    func updateTaskStatus(_ taskId: UUID, status: TaskStatus) async throws {
        try await db.collection("tasks").document(taskId.uuidString).updateData([
            "status": status.rawValue
        ])
    }
    
}
