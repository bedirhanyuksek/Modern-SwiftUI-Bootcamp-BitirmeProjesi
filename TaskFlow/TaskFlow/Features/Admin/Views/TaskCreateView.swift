//
//  TaskCreateView.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import SwiftUI

struct TaskCreateView: View {
    @ObservedObject var viewModel: TaskCreateViewModel
    
    
    var body: some View {
        Form {
            Section(header: Text("Görev Bilgileri")) {
                TextField("Başlık", text: $viewModel.title)
                TextField("Açıklama", text: $viewModel.description)
                DatePicker("Başlangıç Tarihi", selection: $viewModel.date, displayedComponents: .date)
                DatePicker("SLA Son Tarihi", selection: Binding(
                    get: { viewModel.slaDeadline ?? Date() },
                    set: { viewModel.slaDeadline = $0 }
                ), displayedComponents: .date)
                
                if viewModel.isLoadingUsers {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Kullanıcılar yükleniyor...")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else if !viewModel.users.isEmpty {
                    Picker(selection: $viewModel.assignedTo) {
                        Text("Kullanıcı Seçiniz").tag(nil as String?)
                        ForEach(viewModel.users, id: \.uid) { user in
                            Text("\(user.email) (\(user.role == .admin ? "Yönetici" : "Personel"))").tag(user.uid as String?)
                        }
                    } label: {
                        Text("Atanacak Kullanıcı")
                    }
                } else {
                    Text("Kullanıcı bulunamadı")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }//Section
            
            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            
            Button{
                Task{ await viewModel.createTask() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Görev Oluştur")
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(viewModel.isLoading)
            
            
        }//Form
        
        .navigationTitle("Görev Oluştur")
        .task {
            await viewModel.loadUsers()
        }
    }
}
