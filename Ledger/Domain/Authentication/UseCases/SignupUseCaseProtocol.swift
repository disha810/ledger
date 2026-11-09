//
//  SignupUseCaseProtocol.swift
//  Ledger
//
//  Created by Divya on 05/11/26.
//

import Combine

protocol SignupUseCaseProtocol {
    func execute(name: String, email: String,
                 username: String, password: String) -> AnyPublisher<AuthSession, AuthError>
}
