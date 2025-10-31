//
//  FirebaseAuthRepository.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class FirebaseAuthRepository: AuthRepository, ObservableObject {
    private let db = Firestore.firestore()
    
    @Published private(set) var currentUser: UserSession?
    
    func signIn(email: String, password: String) async throws -> UserSession {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = result.user
        let role = try await fetchUserRole(uid: user.uid)
        let session = UserSession(uid: user.uid, email: user.email ?? "",role: role)
        currentUser = session
        return session
        
    }
    
    func signOut() async throws {
        try Auth.auth().signOut()
        currentUser = nil
    }
    
    func register(email: String, password: String, role: UserRole) async throws -> UserSession {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = result.user
        try await db.collection("users").document(user.uid).setData([
            "email": email,
            "role": role == .admin ? "admin" : "staff"
        ])
        
        let session = UserSession(uid: user.uid, email: email,role: role)
        currentUser = session
        return session
      
    }
    
    private func fetchUserRole(uid: String) async throws -> UserRole {
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let data = doc.data(), let roleStr = data["role"] as? String else{
            return .staff
        }
        return roleStr == "admin" ? .admin : .staff
    }
    
}
