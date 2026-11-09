//
//  LoginUseCaseProtocol.swift
//  Ledger
//
//  Created by Divya on 03/11/26.
//

import Combine

protocol LoginUseCaseProtocol {
    func execute(
        identifier: String,
        password: String
    ) -> AnyPublisher<AuthSession, AuthError>
}
