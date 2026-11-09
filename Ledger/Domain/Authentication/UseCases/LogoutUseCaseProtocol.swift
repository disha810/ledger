//
//  LogoutUseCaseProtocol.swift
//  Ledger
//
//  Created by Divya on 08/11/26.
//

import Combine

protocol LogoutUseCaseProtocol {
    func execute() -> AnyPublisher<Void, AuthError>
}
