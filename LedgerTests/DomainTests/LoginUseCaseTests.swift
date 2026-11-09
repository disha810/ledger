//
//  LoginUseCaseTests.swift
//  LedgerTests
//
//  Created by Divya on 31/10/26.
//

import XCTest
import Combine
@testable import Ledger

final class LoginUseCaseTests: XCTestCase {
    
    var authRepository: MockAuthRepository!
    var sessionRepository: MockSessionRepository!
    var sut: LoginUseCase!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        
        authRepository = MockAuthRepository()
        sessionRepository = MockSessionRepository()
        sut = LoginUseCase(authRepository: authRepository,
                           sessionRepository: sessionRepository)
        cancellables = []
    }

    override func tearDown() {
        authRepository = nil
        sessionRepository = nil
        sut = nil
        cancellables = nil
        
        super.tearDown()
    }

    func testLoginwithEmptyIdentifierReturnInvalidInput() {
        
        let expectation = expectation(description: "Invalid Input")
        
        sut?.execute(identifier: "", password: "12345")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error, AuthError.invalidInput)
                    expectation.fulfill()
                }
                
            }, receiveValue: { _ in
                XCTFail("Login should not succeed")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testLoginAndSessionPersistenceSuccess() {
        let expectation = expectation(description: "Login and session persistence should succeed")
        
        let identifier = "testuser"
        let password = "test"
        
        let user = User(id: UUID().uuidString,
                        name: identifier,
                        email: "\(identifier)@gmail.com",
                        username: identifier)
        
        let authSession = AuthSession(user: user, accessToken: UUID().uuidString)
        
        authRepository.loginResult = authSession
        
        sut.execute(identifier: identifier, password: password)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(_):
                    XCTFail("Login should not fail")
                }
            }, receiveValue: { result in
                XCTAssertEqual(result, authSession)
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testLoginFailsWhenPersistenceFails() {
        let expectation = expectation(description: "Session persistence fails")
        
        let identifier = "testuser"
        let password = "test"
        
        let user = User(id: UUID().uuidString,
                        name: identifier,
                        email: "\(identifier)@gmail.com",
                        username: identifier)
        
        let authSession = AuthSession(user: user, accessToken: UUID().uuidString)
        
        authRepository.loginResult = authSession

        sessionRepository.sessionError = .storageFailure
        
        sut.execute(identifier: identifier, password: password)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Login should fail")
                case .failure(let error):
                    XCTAssertEqual(error,
                                   AuthError.sessionPersistenceFailed(.storageFailure))
                    XCTAssertEqual(self.sessionRepository.saveCallCount, 1)
                    expectation.fulfill()
                }
            }, receiveValue: { result in
                XCTFail("Persistence failure should not return session")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testLoginFailsWithoutPersistingSession() {
        let expectation = expectation(description: "Session persistence fails")
        
        let identifier = "testuser"
        let password = "test"
        
        let user = User(id: UUID().uuidString,
                        name: identifier,
                        email: "\(identifier)@gmail.com",
                        username: identifier)
        
        let authSession = AuthSession(user: user, accessToken: UUID().uuidString)
        
        authRepository.loginResult = authSession

        sessionRepository.sessionError = .storageFailure
        
        sut.execute(identifier: "invalid identifier", password: password)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Login should fail")
                case .failure(let error):
                    XCTAssertEqual(error,
                                   AuthError.invalidCredentials)
                    XCTAssertEqual(self.sessionRepository.saveCallCount, 0)
                    expectation.fulfill()
                }
            }, receiveValue: { result in
                XCTFail("Login failure should not return session")
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
}
