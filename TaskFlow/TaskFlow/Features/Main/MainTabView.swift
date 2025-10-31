//
//  MainTabView.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 27.10.2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    let repository: TaskRepository
    
    var body: some View {
        if let session = appState.session {
            TabView {
                // Anasayfa
                HomeView(viewModel: HomeViewModel(repository: repository, appState: appState))
                    .tabItem {
                        Label("Anasayfa", systemImage: "house")
                    }
                
                // Görevler
                TaskListView(viewModel: TaskListViewModel(repository: repository, appState: appState))
                    .tabItem {
                        Label("Görevler", systemImage: "list.bullet")
                    }
                
                // Admin için görev oluşturma
                if session.role == .admin {
                    TaskCreateView(viewModel: TaskCreateViewModel(repository: repository, appState: appState))
                        .tabItem {
                            Label("Yeni Görev", systemImage: "plus.circle")
                        }
                }
                
                // Ayarlar
                SettingsView(viewModel: SettingsViewModel(appState: appState))
                    .tabItem {
                        Label("Ayarlar", systemImage: "gearshape")
                    }
            }//TabView
        }
    }
}
