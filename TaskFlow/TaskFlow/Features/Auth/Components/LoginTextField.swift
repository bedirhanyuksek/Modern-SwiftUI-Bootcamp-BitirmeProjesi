//
//  LoginTextField.swift
//  TaskFlow
//
//  Created by Bedirhan Yüksek on 27.10.2025.
//

import SwiftUI

struct LoginTextField: View {
    
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        
        Group{
            if isSecure {
                SecureField(placeholder, text: $text)
            }else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    
            }
        }
        
    }
}
