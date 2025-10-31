//
//  RegisterViewModel.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import Foundation
import FirebaseAuth

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var rePassword = ""
    @Published var role: UserRole = .staff
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isLoading = false
    
    private let authRepository: AuthRepository
    private let appState: AppState
    
    init(authRepository: AuthRepository, appState: AppState){
        self.authRepository = authRepository
        self.appState = appState
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func getFirebaseErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        let errorCode = nsError.code
        
        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError,
           let deserializedResponse = underlyingError.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as? [String: Any],
           let message = deserializedResponse["message"] as? String,
           message == "CONFIGURATION_NOT_FOUND" {
            return "Firebase yapılandırması eksik. Firebase Console'da Email/Password authentication'ı etkinleştirin."
        }
        
        switch errorCode {
        case 17007:
            return "Bu e-posta adresi zaten kullanılıyor."
        case 17008: 
            return "Geçersiz e-posta adresi."
        case 17026:
            return "Şifre çok zayıf. En az 6 karakter olmalıdır."
        case 17020:
            return "Ağ hatası. İnternet bağlantınızı kontrol edin."
        case 17006:
            return "Bu işlem şu anda izin verilmiyor. Firebase Console'da Email/Password authentication'ı etkinleştirin."
        case 17999: 
            if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError,
               let deserializedResponse = underlyingError.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as? [String: Any],
               let message = deserializedResponse["message"] as? String {
                if message == "CONFIGURATION_NOT_FOUND" {
                    return "Firebase yapılandırması eksik. Firebase Console'da Email/Password authentication'ı etkinleştirin."
                }
            }
            return "Firebase yapılandırma hatası. Firebase Console'u kontrol edin."
        default:
            return "Kayıt başarısız: \(error.localizedDescription)"
        }
    }
    
    func registerUser() async {
        errorMessage = nil
        successMessage = nil
        
        guard !email.isEmpty && !password.isEmpty && !rePassword.isEmpty else {
            errorMessage = "Tüm alanlar doldurulmalı."
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Geçerli bir e-posta adresi giriniz."
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Şifre en az 6 karakter olmalıdır."
            return
        }
        
        guard password == rePassword else {
            errorMessage = "Şifreler eşleşmiyor."
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let session = try await authRepository.register(email: email, password: password, role: role)
            appState.session = session
            successMessage = "Kayıt başarılı."
            errorMessage = nil
        } catch {
            errorMessage = getFirebaseErrorMessage(error)
            print("Kayıt hatası: \(error)")
        }
    }
    
    
}
