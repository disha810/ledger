//
//  MockSignupUseCase.swift
//  Ledger
//
//  Created by Divya on 06/11/26.
//

import Combine
@testable import Ledger

final class MockSignupUseCase: SignupUseCaseProtocol {
    
    private(set) var receivedName: String?
    private(set) var receivedEmail: String?
    private(set) var receivedUserName: String?
    private(set) var receivedPassword: String?
    
    var subject: PassthroughSubject<AuthSession, AuthError>?
    
    private(set) var executeCallCount = 0
    private(set) var isCancelled = false
    
    func execute(name: String, email: String, username: String, password: String) -> AnyPublisher<Ledger.AuthSession, Ledger.AuthError> {
        executeCallCount += 1
        
        receivedName = name
        receivedEmail = email
        receivedUserName = username
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
