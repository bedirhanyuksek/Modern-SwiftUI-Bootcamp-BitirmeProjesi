//
//  TaskDetailView.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import SwiftUI

struct TaskDetailView: View {
    @ObservedObject var viewModel: TaskDetailViewModel
    @State private var showingPDFShare = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Başlık
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.task.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Durum badge
                    HStack {
                        StatusBadge(status: viewModel.task.status)
                        Spacer()
                        SLABadge(status: viewModel.task.slaStatus)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Detaylar
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(label: "Açıklama", value: viewModel.task.description)
                    DetailRow(label: "Durum", value: viewModel.statusText(viewModel.task.status))
                    
                    if let assignedTo = viewModel.task.assignedTo {
                        DetailRow(label: "Atanan", value: assignedTo)
                    }
                    
                    DetailRow(label: "Başlangıç Tarihi", value: formatDate(viewModel.task.date))
                    
                    if let slaDeadline = viewModel.task.slaDeadline {
                        DetailRow(label: "SLA Son Tarihi", value: formatDate(slaDeadline))
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Durum güncelleme butonu
                if viewModel.canUpdateStatus, let nextStatus = viewModel.nextStatus {
                    Button {
                        Task {
                            await viewModel.updateStatus()
                        }
                    } label: {
                        HStack {
                            if viewModel.isUpdatingStatus {
                                ProgressView()
                            } else {
                                Image(systemName: "arrow.right.circle")
                            }
                            Text("Durumu Değiştir: \(viewModel.statusText(nextStatus))")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isUpdatingStatus)
                    .padding(.horizontal)
                }
                
                // PDF butonu (sadece tamamlanan görevler için)
                if viewModel.task.status == .done {
                    Button {
                        showingPDFShare = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.fill")
                            Text("PDF Raporu Oluştur")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle("Görev Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPDFShare) {
            PDFShareView(task: viewModel.task)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}


struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .fontWeight(.semibold)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

struct PDFShareView: View {
    let task: TaskModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let pdfURL = PDFService.generatePDF(for: task) {
                    PDFViewer(url: pdfURL)
                    
                    ShareLink(item: pdfURL) {
                        Label("Paylaş", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    .padding()
                } else {
                    Text("PDF oluşturulamadı")
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("PDF Raporu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PDFViewer: View {
    let url: URL
    
    var body: some View {
        Text("PDF Önizleme")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
    }
}

