//
//  MockLoginUseCase.swift
//  Ledger
//
//  Created by Divya on 03/11/26.
//

import Combine
@testable import Ledger

final class MockLoginUseCase: LoginUseCaseProtocol {
    
    private(set) var receivedIdentifier: String?
    private(set) var receivedPassword: String?
    
    var subject: PassthroughSubject<AuthSession, AuthError>?
    
    private(set) var executeCallCount = 0
    private(set) var isCancelled = false
    
    func execute(identifier: String,
                 password: String) -> AnyPublisher<AuthSession, AuthError> {
        executeCallCount += 1
        
        receivedIdentifier = identifier
        receivedPassword = password
        
        let subject = PassthroughSubject<AuthSession, AuthError>()
        self.subject = subject
        
        return subject.handleEvents(receiveCancel: { [weak self] in
            self?.isCancelled = true}
        ).eraseToAnyPublisher()
    }
    
    func sendSuccess(_ session: AuthSession) {
        subject?.send(session)
        subject?.send(completion: .finished)
    }
    
    func sendFailure(_ error : AuthError) {
        subject?.send(completion: .failure(error))
    }
}
