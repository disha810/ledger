//
//  MockRepository.swift
//  Ledger
//
//  Created by Divya on 31/10/26.
//

import Combine
import Foundation
@testable import Ledger

final class MockAuthRepository: AuthRepository {
    
    var loginResult: AuthSession?
    var errorToThrow: AuthError?
    
    func signup(name: String, email: String, username: String, password: String) -> AnyPublisher<AuthSession, AuthError> {
        
        if let errorToThrow {
            return Fail(error: errorToThrow).eraseToAnyPublisher()
        }
        
        let user = User(id: UUID().uuidString,
                        name: name,
                        email: email,
                        username: password)
        
        loginResult = AuthSession(user: user, accessToken: UUID().uuidString)
        
        return Just(loginResult!)
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        
    }
    
    func login(identifier: String, password: String) -> AnyPublisher<AuthSession, AuthError> {
        if let errorToThrow {
            return Fail(error: errorToThrow).eraseToAnyPublisher()
        }
        
        if let loginResult {
            if loginResult.user.email.lowercased() == identifier.lowercased() ||
                loginResult.user.username.lowercased() == identifier.lowercased(){
                return Just(loginResult)
                        .setFailureType(to: AuthError.self)
                        .eraseToAnyPublisher()
            }
            return Fail(error: AuthError.invalidCredentials).eraseToAnyPublisher()
        }
        return Fail(error: AuthError.unknown).eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, Ledger.AuthError> {
        Just(())
            .setFailureType(to: AuthError.self)
            .eraseToAnyPublisher()
    }
}
