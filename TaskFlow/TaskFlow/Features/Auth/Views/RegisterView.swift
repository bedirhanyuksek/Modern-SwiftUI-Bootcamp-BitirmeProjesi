//
//  RegisterView.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RegisterViewModel
    
    
    var body: some View {
        Form{
            Section(header: Text("Kullanıcı Bilgileri")) {
                TextField("E-posta", text: $viewModel.email)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                
                SecureField("Şifre", text: $viewModel.password)
                    
                
                SecureField("Şifre Tekrar", text: $viewModel.rePassword)
                   
                    
                Picker(selection: $viewModel.role) {
                    ForEach(UserRole.allCases, id: \.self) { role in
                        Text(role == .admin ? "Yönetici" : "Personel")
                            .tag(role)
                    }
                } label: {
                    Text("Rol")
                }
            }
            
            if let error = viewModel.errorMessage{
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
            
            Button("Kaydet") {
                Task { await viewModel.registerUser() }
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            
            if let success = viewModel.successMessage{
                Text(success)
                    .foregroundStyle(.green)
                    .font(.footnote)
                    .onAppear {
                        // Başarılı kayıt sonrası 1.5 saniye bekle ve kapat
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }
            }
        }//Form
        .navigationTitle("Kullanıcı Ekle")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Kapat") {
                    dismiss()
                }
            }
        }
    }
}
