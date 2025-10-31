//
//  UserSession.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 27.10.2025.
//

import Foundation

enum UserRole: String, Codable, CaseIterable, Hashable { case admin, staff }

struct UserSession: Codable, Sendable {
    let uid: String
    let email: String
    let role: UserRole
}
