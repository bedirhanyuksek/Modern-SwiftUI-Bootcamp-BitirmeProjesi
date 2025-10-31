//
//  HomeView.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let session = appState.session {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hoş Geldiniz")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(session.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                    
                    if viewModel.isLoading {
                        ProgressView("Yükleniyor...")
                            .padding()
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatCard(title: "Toplam Görev", value: "\(viewModel.totalTasks)", color: .blue, icon: "list.bullet")
                            StatCard(title: "Bekleyen", value: "\(viewModel.pendingTasks)", color: .orange, icon: "clock")
                            StatCard(title: "Tamamlanan", value: "\(viewModel.completedTasks)", color: .green, icon: "checkmark.circle")
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 12) {
                        NavigationLink {
                            TaskListView(viewModel: TaskListViewModel(repository: viewModel.repository, appState: appState))
                        } label: {
                            QuickActionCard(title: "Görevler", icon: "list.bullet", color: .blue)
                        }
                        
                        if appState.session?.role == .admin {
                            NavigationLink {
                                TaskCreateView(viewModel: TaskCreateViewModel(repository: viewModel.repository, appState: appState))
                            } label: {
                                QuickActionCard(title: "Yeni Görev", icon: "plus.circle", color: .green)
                            }
                        }
                        
                        NavigationLink {
                            SettingsView(viewModel: SettingsViewModel(appState: appState))
                        } label: {
                            QuickActionCard(title: "Ayarlar", icon: "gearshape", color: .gray)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
                .padding(.vertical)
            }
            .navigationTitle("TaskFlow")
            .task {
                await viewModel.loadStatistics()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

