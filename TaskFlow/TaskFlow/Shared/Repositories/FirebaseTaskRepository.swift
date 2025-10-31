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
    
    func fetchTasks(for user: UserSession?) async throws -> [TaskModel] {
        if let user, user.role != .admin {
            let tasksRef = db.collection("tasks")
            var documents: [QueryDocumentSnapshot] = []
            var seenIDs = Set<String>()
            
            func appendUnique(_ docs: [QueryDocumentSnapshot]) {
                for doc in docs where seenIDs.insert(doc.documentID).inserted {
                    documents.append(doc)
                }
            }
            
            let uidSnapshot = try await tasksRef
                .whereField("assignedTo", isEqualTo: user.uid)
                .getDocuments()
            appendUnique(uidSnapshot.documents)
            
            let trimmedEmail = user.email.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedEmail.isEmpty {
                let emailAssignedSnapshot = try await tasksRef
                    .whereField("assignedTo", isEqualTo: trimmedEmail)
                    .getDocuments()
                appendUnique(emailAssignedSnapshot.documents)
                
                let legacyEmailSnapshot = try await tasksRef
                    .whereField("assignedEmail", isEqualTo: trimmedEmail)
                    .getDocuments()
                appendUnique(legacyEmailSnapshot.documents)
            }
            
            if documents.isEmpty {
                let snapshot = try await tasksRef.getDocuments()
                let fallbackTasks = snapshot.documents
                    .compactMap(makeTask(from:))
                    .filter { $0.isAssigned(to: user) }
                self.tasks = fallbackTasks
                return fallbackTasks
            }
            
            let fetchedTasks = documents
                .compactMap(makeTask(from:))
                .filter { $0.isAssigned(to: user) }
            self.tasks = fetchedTasks
            return fetchedTasks
        } else {
            let snapshot = try await db.collection("tasks").getDocuments()
            let fetchedTasks = snapshot.documents.compactMap(makeTask(from:))
            self.tasks = fetchedTasks
            return fetchedTasks
        }
    }
    
    func createTask(_ task: TaskModel) async throws {
        let assignedToValue = task.assignedTo?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let assignedEmailValue = task.assignedEmail?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !assignedEmailValue.isEmpty {
        }
        
        guard !assignedToValue.isEmpty else {
            throw NSError(domain: "FirebaseTaskRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görev atanacak kullanıcı belirtilmedi."])
        }
        
        var taskData: [String: Any] = [
            "title": task.title,
            "description": task.description,
            "status": task.status.rawValue,
            "date": Timestamp(date: task.date),
            "assignedTo": assignedToValue
        ]
        
        if !assignedEmailValue.isEmpty {
            taskData["assignedEmail"] = assignedEmailValue
        }
        
        if let slaDeadline = task.slaDeadline {
            taskData["slaDeadline"] = Timestamp(date: slaDeadline)
        }
        
        
        try await db.collection("tasks").document(task.id.uuidString).setData(taskData)
        
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

private extension FirebaseTaskRepository {
    func makeTask(from doc: QueryDocumentSnapshot) -> TaskModel? {
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
        
        let assignedEmail: String?
        if let assignedEmailRaw {
            let trimmed = assignedEmailRaw.trimmingCharacters(in: .whitespacesAndNewlines)
            assignedEmail = trimmed.isEmpty ? nil : trimmed
        } else if let assignedToRaw {
            let trimmed = assignedToRaw.trimmingCharacters(in: .whitespacesAndNewlines)
            assignedEmail = trimmed.isEmpty ? nil : trimmed
        } else {
            assignedEmail = nil
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
            assignedEmail: assignedEmail,
            slaDeadline: slaDeadline
        )
    }
}
