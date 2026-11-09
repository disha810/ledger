//
//  AuthError.swift
//  Ledger
//
//  Created by Divya on 31/10/26.
//

import Foundation

enum AuthError: Equatable {
    case invalidInput
    case invalidCredentials
    case emailAlreadyRegistered
    case usernameAlreadyTaken
    case networkError
    case serverError
    case sessionPersistenceFailed(SessionError)
    case clearSessionFailed(SessionError)
    case unknown
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Please check the entered information!"
        case .invalidCredentials:
            return "Invalid username or password"
        case .emailAlreadyRegistered:
            return "This email is already registered"
        case .usernameAlreadyTaken:
            return "This username is already taken"
        case .networkError:
            return "Please check your internet connection"
        case .serverError:
            return "Something went wrong, please try again!"
        case .sessionPersistenceFailed(let sessionError):
            return "Failed to persisit session, \(sessionError.localizedDescription)"
        case .clearSessionFailed(let sessionError):
            return "Failed to clear session, \(sessionError.localizedDescription)"
        case .unknown:
            return "An unexpected error has occured."
        }
    }
}
