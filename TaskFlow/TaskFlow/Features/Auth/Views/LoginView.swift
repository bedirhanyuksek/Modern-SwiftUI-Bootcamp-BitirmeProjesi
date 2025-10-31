//
//  LoginView.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 27.10.2025.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @EnvironmentObject var appState: AppState
    @State private var showRegister = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("TaskFlow")
                .font(.largeTitle)
                .bold()
                .padding(.bottom,30)
            
            LoginTextField(placeholder: "E-posta", text: $viewModel.email)
            LoginTextField(placeholder: "Şifre", text: $viewModel.password, isSecure: true)
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
            
            LoginButton(action: {
                Task {
                    await viewModel.signIn()
                }
            }, isLoading: viewModel.isLoading)
            
            Button("Kayıt Ol") {
                showRegister = true
            }
            .font(.footnote)
            .padding(.top,10)
            
            Spacer()
            
        }//VStack
        .padding()
        .sheet(isPresented: $showRegister) {
            NavigationStack{
                RegisterView(viewModel: RegisterViewModel(authRepository: viewModel.auth, appState: appState))
            }
        }
    }
}


