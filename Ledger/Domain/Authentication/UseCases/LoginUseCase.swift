//
//  LoginUseCase.swift
//  Ledger
//
//  Created by Divya on 31/10/26.
//

import Combine
import Foundation

final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepository
    private let sessionRepository: SessionRepository
    
    init(authRepository: AuthRepository,
         sessionRepository: SessionRepository) {
        self.authRepository = authRepository
        self.sessionRepository = sessionRepository
    }
    
    func execute(identifier: String, password: String) -> AnyPublisher<AuthSession, AuthError> {
        
        let normalizedIdentifier = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !normalizedIdentifier.isEmpty,
              !password.isEmpty else {
            return Fail(error: AuthError.invalidInput).eraseToAnyPublisher()
        }
        
        return authRepository.login(identifier: normalizedIdentifier, password: password)
            .flatMap { authSession in
                self.sessionRepository.save(authSession)
                    .mapError { error in
                        AuthError.sessionPersistenceFailed(error)
                    }
                    .map { _ in
                        authSession
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
    }
}
