//
//  AuthRepositoryImpl.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

import Combine

final class AuthRepositoryImpl: AuthRepository {
    let dataSource: AuthDataSource
    
    init(dataSource: AuthDataSource) {
        self.dataSource = dataSource
    }
    
    func signup(name: String,
                email: String,
                username: String,
                password: String) -> AnyPublisher<AuthSession, AuthError> {
        dataSource.signup(name: name,
                          username: username,
                          email: email,
                          password: password)
        .map {
            AuthMapper.map($0)
        }
        .eraseToAnyPublisher()
    }
    
    func login(identifier: String, password: String) -> AnyPublisher<AuthSession, AuthError> {
        dataSource.login(identifier: identifier,
                         password: password)
        .map {
            AuthMapper.map($0)
        }
        .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, AuthError> {
        dataSource.logout()
            .eraseToAnyPublisher()
    }
    
    
}
