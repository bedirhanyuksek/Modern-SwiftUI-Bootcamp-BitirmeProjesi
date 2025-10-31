//
//  TaskListView.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack{
            Group{
                if viewModel.isLoading{
                    ProgressView("Görevler Yükleniyor...")
                } else if viewModel.tasks.isEmpty {
                    ContentUnavailableView("Henüz görev yok", systemImage: "tray")
                } else {
                    List{
                        ForEach (viewModel.tasks) {task in
                            NavigationLink {
                                TaskDetailView(viewModel: TaskDetailViewModel(
                                    task: task,
                                    repository: viewModel.repository,
                                    appState: appState
                                ))
                            } label: {
                                TaskRow(task: task)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if appState.session?.role == .admin {
                                    Button(role: .destructive) {
                                        Task { await viewModel.deleteTask(id: task.id)}
                                    } label: {
                                        Label("Sil",systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                    
                
            }//Group
            .navigationTitle("Görevler")
            .task {
                await viewModel.loadTasks()
            }
        }
    }
}
