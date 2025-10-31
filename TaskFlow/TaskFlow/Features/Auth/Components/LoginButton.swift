//
//  LoginButton.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 27.10.2025.
//

import SwiftUI

struct LoginButton: View {
    let action: () -> Void
    let isLoading: Bool
    
    var body: some View {
        Button(action: action) {
            Text("Giriş Yap")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .disabled(isLoading)
        }
        
    }
}
