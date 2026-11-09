//
//  LoginRepository.swift
//  Ledger
//
//  Created by Divya on 31/10/26.
//

import Combine

protocol AuthRepository {
    func signup(name: String, email: String,
                username: String, password: String) -> AnyPublisher<AuthSession, AuthError>
    
    func login(identifier: String, password: String) -> AnyPublisher<AuthSession, AuthError>
    
    func logout() -> AnyPublisher<Void, AuthError>
}
