//
//  AuthRepository.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 27.10.2025.
//

@MainActor
protocol AuthRepository {
    var currentUser: UserSession? { get }
    func signIn(email: String, password: String) async throws -> UserSession
    func signOut() async throws
    func register(email: String, password: String, role: UserRole) async throws -> UserSession
}
