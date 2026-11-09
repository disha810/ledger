//
//  LogoutUseCase.swift
//  Ledger
//
//  Created by Divya on 31/10/26.
//

import Combine
import Foundation

final class LogoutUseCase: LogoutUseCaseProtocol {
    let authRepository: AuthRepository
    let sessionRepository: SessionRepository
    
    init(authRepository: AuthRepository,
         sessionRepository: SessionRepository) {
        self.authRepository = authRepository
        self.sessionRepository = sessionRepository
    }
    
    func execute() -> AnyPublisher<Void, AuthError> {
        authRepository
            .logout()
            .flatMap {
                self.sessionRepository.clearSession()
                    .mapError { AuthError.clearSessionFailed($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
