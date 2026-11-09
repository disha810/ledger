//
//  AuthValidator.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

import Foundation

struct AuthValidator {
    static func validateEmail(_ email: String) -> String? {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        
        guard email.range(of: pattern,
                          options: .regularExpression) != nil else {
            return "Enter a valid email"
        }
        
        return nil
    }
    
    static func validateUsername(_ username: String) -> String? {
        let pattern = #"^[A-Za-z0-9]+(?:[._-][A-Za-z0-9]+)*$"#
        
        guard username.range(of: pattern,
                          options: .regularExpression) != nil else {
            return "Enter a valid username"
        }
        
        return nil
    }
    
    static func validatePassword(_ password: String) -> String? {
        guard password.count >= 8 else {
            return "Password must contain at least 8 characters."
        }
        
        return nil
    }
}
