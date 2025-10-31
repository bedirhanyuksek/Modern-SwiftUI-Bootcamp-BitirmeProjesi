//
//  ProfileView.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing:20){
            if let user = appState.session {
                Text("Hoş geldin, \(user.email)")
                    .font(.headline)
                Text("Rol: \(user.role == .admin ? "Yönetici" : "Kullanıcı")")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(role: .destructive) {
                withAnimation {
                    appState.session = nil
                }
            } label: {
                Text("Çıkış Yap")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color .red)
                    .foregroundStyle(.white)
                    
            }
        }//VStack
        .padding()
        .navigationTitle("Profil")
        
    }
}
