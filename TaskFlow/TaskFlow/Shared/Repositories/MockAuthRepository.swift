//
//  MockAuthRepository.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 27.10.2025.
//

import Foundation

@MainActor
final class MockAuthRepository: AuthRepository, ObservableObject {
    private(set) var currentUser: UserSession?
    private(set) var registeredUsers: [UserSession] = []
    
    func signIn(email: String, password: String) async throws -> UserSession {
        
        try await Task.sleep(for: .seconds(1))
        guard password == "123456" else {
            throw NSError(domain: "MockAuthRepository", code: 401, userInfo: [NSLocalizedDescriptionKey : "Invalid credentials"])
        }
        
        
        let role: UserRole = email.lowercased() == "admin@demo.com" ? .admin : .staff
        let session = UserSession(uid: UUID().uuidString, email: email, role: role)
        currentUser = session
        return session
    }
    func signOut() async throws {
        currentUser = nil
    }
    
    func register(email: String, password: String, role: UserRole) async throws -> UserSession {
        try await Task.sleep(for: .seconds(1))
        let newUser = UserSession(uid: UUID().uuidString, email: email, role: role)
        registeredUsers.append(newUser)
        return newUser
    }
}
