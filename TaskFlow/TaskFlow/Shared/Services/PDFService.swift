//
//  PDFService.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 31.10.2025.
//

import Foundation
import PDFKit
import UIKit

struct PDFService {
    static func generatePDF(for task: TaskModel) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "TaskFlow",
            kCGPDFContextAuthor: "TaskFlow App",
            kCGPDFContextTitle: task.title
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 72
            
            // Başlık
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let title = task.title as NSString
            title.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Görev Raporu label
            let reportLabelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.gray
            ]
            "Görev Raporu".draw(at: CGPoint(x: 72, y: yPosition), withAttributes: reportLabelAttributes)
            yPosition += 30
            
            // Ayırıcı çizgi
            context.cgContext.setStrokeColor(UIColor.gray.cgColor)
            context.cgContext.setLineWidth(1.0)
            context.cgContext.move(to: CGPoint(x: 72, y: yPosition))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - 72, y: yPosition))
            context.cgContext.strokePath()
            yPosition += 30
            
            // Detaylar
            let detailAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "tr_TR")
            
            let details = [
                "Açıklama: \(task.description)",
                "Durum: \(statusText(task.status))",
                "Başlangıç Tarihi: \(dateFormatter.string(from: task.date))",
                task.slaDeadline != nil ? "SLA Son Tarihi: \(dateFormatter.string(from: task.slaDeadline!))" : "SLA Son Tarihi: Belirtilmemiş"
            ]
            
            for detail in details {
                detail.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: detailAttributes)
                yPosition += 20
            }
            
            yPosition += 20
            
            // Oluşturulma tarihi
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            let footerText = "Rapor Oluşturulma Tarihi: \(dateFormatter.string(from: Date()))"
            footerText.draw(at: CGPoint(x: 72, y: pageHeight - 50), withAttributes: footerAttributes)
        }
        
        // Geçici dosya olarak kaydet
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(task.id.uuidString).pdf")
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("PDF yazma hatası: \(error)")
            return nil
        }
    }
    
    private static func statusText(_ status: TaskStatus) -> String {
        switch status {
        case .planned: return "Planlandı"
        case .todo: return "Yapılacak"
        case .inProgress: return "Çalışmada"
        case .control: return "Kontrol"
        case .done: return "Tamamlandı"
        }
    }
}

