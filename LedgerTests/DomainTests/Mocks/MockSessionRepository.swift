//
//  MockSessionRepository'.swift
//  Ledger
//
//  Created by Divya on 03/11/26.
//

import Combine
import Foundation
@testable import Ledger

final class MockSessionRepository: SessionRepository {
    
    private(set) var session: AuthSession?
    
    var sessionError: SessionError?
    
    private(set) var saveCallCount = 0
    
    
    func save(_ session: Ledger.AuthSession) -> AnyPublisher<Void, Ledger.SessionError> {
        saveCallCount += 1
        
        if let sessionError {
            return Fail(error: sessionError)
                .eraseToAnyPublisher()
        }
        
        self.session = session
        
        return Just(())
                .setFailureType(to: SessionError.self)
                .eraseToAnyPublisher()
    }
    
    func getSession() -> AnyPublisher<Ledger.AuthSession?, Ledger.SessionError> {
        Just(session)
            .setFailureType(to: SessionError.self)
            .eraseToAnyPublisher()
    }
    
    func clearSession() -> AnyPublisher<Void, Ledger.SessionError> {
        self.session = nil
        
        return Just(())
                .setFailureType(to: SessionError.self)
                .eraseToAnyPublisher()
    }
    

}
