//
//  MockDataSource.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

import Combine
import Foundation

final class MockDataSource: AuthDataSource {
    
    private struct StoredUser {
        let user: UserDTO
        let password: String
    }
    
    private var storedUsers: [String: StoredUser] = [:]
    
    private var queue = DispatchQueue(label: "com.ledger.mock-auth")
    
    private let responseDelay: DispatchTimeInterval = .milliseconds(700)
    
    func signup(name: String,
                username:String,
                email: String,
                password: String) -> AnyPublisher<AuthSessionDTO, AuthError> {
        Deferred { [weak self] in
            Future<AuthSessionDTO, AuthError> { [weak self] promise in
                guard let self else {
                    return promise(.failure(AuthError.unknown))
                }
    
                queue.asyncAfter(deadline: .now() + responseDelay) {
                    let normalizedUsername = username.lowercased()
                    let normalizedEmail = email.lowercased()
                    
                    guard !self.storedUsers.values.contains(where: {
                        $0.user.username.lowercased() == normalizedUsername
                    }) else {
                        return promise(.failure(AuthError.usernameAlreadyTaken))
                    }
                    
                    guard !self.storedUsers.values.contains(where: {
                        $0.user.email.lowercased() == normalizedEmail
                    }) else {
                        return promise(.failure(AuthError.emailAlreadyRegistered))
                    }
                    
                    let user = UserDTO(id: UUID().uuidString,
                                       name: name,
                                       email: email,
                                       username: username)
                    
                    self.storedUsers[user.id] = StoredUser(user: user,
                                                      password: password)
                    
                    let authSession = AuthSessionDTO(user: user,
                                                     accessToken: UUID().uuidString)
                    
                    promise(.success(authSession))

                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func login(identifier: String,
               password: String) -> AnyPublisher<AuthSessionDTO, AuthError> {
        Future { [weak self] promise in
            
            guard let self else {
                return promise(.failure(AuthError.unknown))
            }
            
            let normalizedIdentifier = identifier.lowercased()
            
            let user = storedUsers.values.first(where: {
                $0.user.username.lowercased() == normalizedIdentifier ||
                $0.user.email.lowercased() == normalizedIdentifier
            })
            
            guard let user,
                    user.password == password else {
                return promise(.failure(AuthError.invalidCredentials))
            }
                    
            let authSession = AuthSessionDTO(user: user.user,
                                             accessToken: UUID().uuidString)
            
            promise(.success(authSession))
            
        }
        .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, AuthError> {
        Just(())
            .setFailureType(to: AuthError.self)
            .eraseToAnyPublisher()
    }
}
