//
//  AuthDataSource.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

import Combine

protocol AuthDataSource {
    func signup(name: String,
                username: String,
                email: String,
                password: String) -> AnyPublisher<AuthSessionDTO, AuthError>
    func login(identifier: String,
               password: String) -> AnyPublisher<AuthSessionDTO, AuthError>
    func logout() -> AnyPublisher<Void, AuthError>
}
