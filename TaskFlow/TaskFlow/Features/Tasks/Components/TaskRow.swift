//
//  TaskRow.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import SwiftUI

struct TaskRow: View {
    let task: TaskModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.title)
                    .font(.headline)
                Spacer()
                if task.slaStatus != .noDeadline {
                    SLABadge(status: task.slaStatus)
                }
            }
            
            Text(task.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            HStack {
                StatusBadge(status: task.status)
                Spacer()
                Text("Tarih: \(task.date, style: .date)")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        }//VStack
        .padding(.vertical, 6)
        .listRowBackground(rowBackgroundColor)
    }
    
    private var rowBackgroundColor: Color {
        switch task.slaStatus {
        case .overdue: return Color.red.opacity(0.1)
        case .urgent: return Color.orange.opacity(0.1)
        case .warning: return Color.orange.opacity(0.05)
        default: return Color.clear
        }
    }
}

struct StatusBadge: View {
    let status: TaskStatus
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .foregroundStyle(.white)
            .cornerRadius(6)
    }
    
    private var statusText: String {
        switch status {
        case .planned: return "Planlandı"
        case .todo: return "Yapılacak"
        case .inProgress: return "Çalışmada"
        case .control: return "Kontrol"
        case .done: return "Tamamlandı"
        }
    }
    
    private var color: Color {
        switch status {
        case .planned: return .gray
        case .todo: return .blue
        case .inProgress: return .orange
        case .control: return .purple
        case .done: return .green
        }
    }
}

struct SLABadge: View {
    let status: SLAStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
        }
        .font(.caption2)
        .fontWeight(.semibold)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.2))
        .foregroundStyle(color)
        .cornerRadius(4)
    }
    
    private var text: String {
        switch status {
        case .noDeadline: return "SLA Yok"
        case .normal: return "Normal"
        case .warning: return "Uyarı"
        case .urgent: return "Acil"
        case .overdue: return "Gecikmiş"
        }
    }
    
    private var icon: String {
        switch status {
        case .noDeadline: return "minus.circle"
        case .normal: return "checkmark.circle"
        case .warning: return "exclamationmark.triangle"
        case .urgent: return "exclamationmark.circle.fill"
        case .overdue: return "xmark.circle.fill"
        }
    }
    
    private var color: Color {
        switch status {
        case .noDeadline: return .gray
        case .normal: return .green
        case .warning: return .orange
        case .urgent: return .orange
        case .overdue: return .red
        }
    }
}

