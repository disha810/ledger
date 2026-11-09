//
//  Signup.swift
//  Ledger
//
//  Created by Divya on 31/10/26.
//

import Combine
import Foundation

final class SignupUseCase: SignupUseCaseProtocol {
    let authRepository: AuthRepository
    let sessionRepository: SessionRepository
    
    init(authRepository: AuthRepository,
         sessionRepository: SessionRepository) {
        self.authRepository = authRepository
        self.sessionRepository = sessionRepository
    }
    
    func execute(name: String, email: String,
                 username: String, password: String) -> AnyPublisher<AuthSession, AuthError> {
        
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !normalizedName.isEmpty,
              !normalizedEmail.isEmpty,
              !normalizedUsername.isEmpty,
              !password.isEmpty else {
            return Fail(error: AuthError.invalidInput).eraseToAnyPublisher()
        }
        
        return authRepository.signup(name: normalizedName,
                                     email: normalizedEmail,
                                     username: normalizedUsername,
                                     password: password)
            .flatMap { session in
            self.sessionRepository.save(session)
                .mapError { AuthError.sessionPersistenceFailed($0) }
                .map { session }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
