//
//  TaskModels.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 27.10.2025.
//

import Foundation

enum TaskStatus: String, CaseIterable, Codable {
    
    case planned = "planned"
    case todo = "todo"
    case inProgress = "inProgress"
    case control = "control"
    case done = "done"
    
}


struct TaskModel: Identifiable, Codable{
    let id: UUID
    var title: String
    var description: String
    var assignedTo: String?
    var assignedEmail: String?
    var status: TaskStatus
    var date: Date
    var slaDeadline: Date?
    
    init(id: UUID = UUID(), title: String, description: String, status: TaskStatus = .planned, date: Date, assignedTo: String? = nil, assignedEmail: String? = nil, slaDeadline: Date? = nil){
        self.id = id
        self.title = title
        self.description = description
        self.assignedTo = assignedTo
        self.assignedEmail = assignedEmail
        self.status = status
        self.date = date
        self.slaDeadline = slaDeadline
    }
    
    var slaStatus: SLAStatus {
        guard let deadline = slaDeadline else { return .noDeadline }
        let now = Date()
        let timeRemaining = deadline.timeIntervalSince(now)
        
        if timeRemaining < 0 {
            return .overdue
        } else if timeRemaining < 24 * 60 * 60 {
            return .urgent 
        } else if timeRemaining < 3 * 24 * 60 * 60 {
            return .warning
        } else {
            return .normal 
        }
    }
    
    func isAssigned(to user: UserSession) -> Bool {
        let normalizedUID = user.uid.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedEmail = user.email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let rawAssignedTo = assignedTo?.trimmingCharacters(in: .whitespacesAndNewlines),
           !rawAssignedTo.isEmpty {
            if rawAssignedTo.caseInsensitiveCompare(normalizedUID) == .orderedSame {
                return true
            }
            if rawAssignedTo.caseInsensitiveCompare(normalizedEmail) == .orderedSame {
                return true
            }
        }
        
        if let rawAssignedEmail = assignedEmail?.trimmingCharacters(in: .whitespacesAndNewlines),
           !rawAssignedEmail.isEmpty {
            if rawAssignedEmail.caseInsensitiveCompare(normalizedEmail) == .orderedSame {
                return true
            }
        }
        
        return false
    }
}

enum SLAStatus {
    case noDeadline
    case normal
    case warning
    case urgent
    case overdue
}
