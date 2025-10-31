//
//  AppState.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 27.10.2025.
//

import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var session: UserSession? = nil {
        didSet {
            if let session = session {
                print("Giriş yapıldı: \(session.email) | Role: \(session.role)")
            } else {
                print("oturum kapatıldı")
            }
        }
    }
}
