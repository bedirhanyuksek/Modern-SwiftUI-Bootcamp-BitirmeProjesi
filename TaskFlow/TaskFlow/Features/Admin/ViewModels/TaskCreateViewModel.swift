//
//  TaskCreateViewModel.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class TaskCreateViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var date = Date()
    @Published var slaDeadline: Date?
    @Published var isLoading = false
    @Published var isLoadingUsers = false
    @Published var errorMessage: String?
    @Published var assignedTo: String? {
        didSet {
            if let id = assignedTo, let user = users.first(where: { $0.uid == id }) {
                assignedEmail = user.email
            } else if let id = assignedTo, let currentUser = appState.session, currentUser.uid == id {
                assignedEmail = currentUser.email
            } else {
                assignedEmail = nil
            }
        }
    }
    @Published var assignedEmail: String?
    @Published var users: [UserSession] = []
    
    private let repository: TaskRepository
    private let appState: AppState
    private let db = Firestore.firestore()
    
    init(repository: TaskRepository, appState: AppState) {
        self.repository = repository
        self.appState = appState
        if let currentUser = appState.session, currentUser.role != .admin {
            self.assignedTo = currentUser.uid
            self.assignedEmail = currentUser.email
        }
    }
    
    func loadUsers() async {
        guard appState.session?.role == .admin else {
            return
        }
        
        guard let firebaseUser = Auth.auth().currentUser else {
            errorMessage = "Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın."
            return
        }
        
        
        isLoadingUsers = true
        errorMessage = nil
        
        do {
          
            let snapshot = try await db.collection("users").getDocuments(source: .default)
            
            let loadedUsers = snapshot.documents.compactMap { doc -> UserSession? in
                let data = doc.data()
                
                guard let email = data["email"] as? String else {
                    return nil
                }
                
                guard let roleStr = data["role"] as? String else {
                    return nil
                }
                
                guard let role = UserRole(rawValue: roleStr) else {
                    return nil
                }
                
                let user = UserSession(uid: doc.documentID, email: email, role: role)
                return user
            }
            
            users = loadedUsers
            
            if let currentAssigned = assignedTo,
               let matched = loadedUsers.first(where: { $0.uid == currentAssigned }) {
                assignedEmail = matched.email
            }
            
            if users.isEmpty {
                errorMessage = "Henüz kayıtlı kullanıcı bulunmuyor."
            }
        } catch {
            let errorMessage = "Kullanıcılar yüklenemedi: \(error.localizedDescription)"
            self.errorMessage = errorMessage
            
            
            if let nsError = error as NSError? {

                if nsError.code == 7 {
                    self.errorMessage = "Firestore izin hatası. Firebase Console'da Firestore Database > Rules bölümünden security rules'ı güncelleyin. Geçici olarak test mode'u etkinleştirebilirsiniz."
                }
            }
        }
        
        isLoadingUsers = false
    }
    
    func createTask() async {
        guard !title.isEmpty else {
            errorMessage = "Görev başlığı boş bırakılamaz."
            return
        }
        
        let finalAssignedTo: String?
        let finalAssignedEmail: String?
        
        if let assigned = assignedTo, !assigned.isEmpty {
            finalAssignedTo = assigned
            if let user = users.first(where: { $0.uid == assigned }) {
                finalAssignedEmail = user.email
            } else if let currentUser = appState.session, currentUser.uid == assigned {
                finalAssignedEmail = currentUser.email
            } else {
                finalAssignedEmail = assignedEmail
            }
        } else if let currentUser = appState.session {
            finalAssignedTo = currentUser.uid
            finalAssignedEmail = currentUser.email
        } else {
            errorMessage = "Kullanıcı bilgisi bulunamadı."
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let task = TaskModel(title: title, description: description, date: date, assignedTo: finalAssignedTo, assignedEmail: finalAssignedEmail, slaDeadline: slaDeadline)
            try await repository.createTask(task)
            title = ""
            description = ""
            date = Date()
            slaDeadline = nil
            assignedTo = nil
            assignedEmail = nil
            errorMessage = nil
        } catch {
            errorMessage = "Görev oluşturulamadı: \(error.localizedDescription)"
        }
        
    }
    
    
}
