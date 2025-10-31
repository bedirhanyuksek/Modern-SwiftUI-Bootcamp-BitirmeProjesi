//
//  SettingsView.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var systemColorScheme
    @AppStorage("colorScheme") private var selectedColorScheme: String = "system"
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Kullanıcı Bilgileri")) {
                    if let session = appState.session {
                        HStack {
                            Text("E-posta")
                            Spacer()
                            Text(session.email)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Rol")
                            Spacer()
                            Text(session.role == .admin ? "Yönetici" : "Personel")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Görünüm")) {
                    Picker("Tema", selection: $selectedColorScheme) {
                        Text("Sistem").tag("system")
                        Text("Açık").tag("light")
                        Text("Koyu").tag("dark")
                    }
                    .onChange(of: selectedColorScheme) { _, newValue in
                        viewModel.colorScheme = colorSchemeFromString(newValue)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.signOut()
                        }
                    } label: {
                        if viewModel.isSigningOut {
                            HStack {
                                ProgressView()
                                Text("Çıkış yapılıyor...")
                            }
                        } else {
                            Text("Çıkış Yap")
                        }
                    }
                    .disabled(viewModel.isSigningOut)
                }
            }
            .navigationTitle("Ayarlar")
            .preferredColorScheme(viewModel.colorScheme ?? colorSchemeFromString(selectedColorScheme))
            .onAppear {
                viewModel.colorScheme = colorSchemeFromString(selectedColorScheme)
            }
        }
    }
    
    private func colorSchemeFromString(_ value: String) -> ColorScheme? {
        switch value {
        case "light": return .light
        case "dark": return .dark
        default: return nil 
        }
    }
}

