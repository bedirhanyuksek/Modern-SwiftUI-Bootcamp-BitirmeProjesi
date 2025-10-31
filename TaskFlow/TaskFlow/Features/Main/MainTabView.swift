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
                HomeView(viewModel: HomeViewModel(repository: repository, appState: appState))
                    .tabItem {
                        Label("Anasayfa", systemImage: "house")
                    }
                
                TaskListView(viewModel: TaskListViewModel(repository: repository, appState: appState))
                    .tabItem {
                        Label("Görevler", systemImage: "list.bullet")
                    }
                
                if session.role == .admin {
                    TaskCreateView(viewModel: TaskCreateViewModel(repository: repository, appState: appState))
                        .tabItem {
                            Label("Yeni Görev", systemImage: "plus.circle")
                        }
                }
                
                SettingsView(viewModel: SettingsViewModel(appState: appState))
                    .tabItem {
                        Label("Ayarlar", systemImage: "gearshape")
                    }
            }//TabView
        }
    }
}
