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
    var status: TaskStatus
    var date: Date
    var slaDeadline: Date?
    
    init(id: UUID = UUID(), title: String, description: String, status: TaskStatus = .planned, date: Date, assignedTo: String? = nil, slaDeadline: Date? = nil){
        self.id = id
        self.title = title
        self.description = description
        self.assignedTo = assignedTo
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
            return .normal // Normal
        }
    }
    
    func isAssigned(to user: UserSession) -> Bool {
        guard let rawAssigned = assignedTo?.trimmingCharacters(in: .whitespacesAndNewlines),
              !rawAssigned.isEmpty else { return false }
        if rawAssigned.caseInsensitiveCompare(user.uid) == .orderedSame {
            return true
        }
        return rawAssigned.caseInsensitiveCompare(user.email) == .orderedSame
    }
}

enum SLAStatus {
    case noDeadline
    case normal
    case warning
    case urgent
    case overdue
}
