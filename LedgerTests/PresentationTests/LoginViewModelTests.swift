//
//  LoginUseCaseTests.swift
//  LedgerTests
//
//  Created by Divya on 31/10/26.
//

import XCTest
import Combine
@testable import Ledger

@MainActor
final class LoginViewModelTests: XCTestCase {
    
    var loginUseCase: MockLoginUseCase!
    var sut: LoginViewModel!
    var cancellable: AnyCancellable?
    
    override func setUp() {
        super.setUp()
        
        loginUseCase = MockLoginUseCase()
        sut = LoginViewModel(loginUseCase: loginUseCase)
    }

    override func tearDown() {
        loginUseCase = nil
        sut = nil
        
        super.tearDown()
    }
    
    func testEmptyIdentifierShowsValidationError() {
        sut.identifier = ""
        sut.password = "password"
        
        sut.signin()
        
        XCTAssertEqual(sut.identifierError, "Enter Username or Email")
        XCTAssertNotEqual(sut.formState, .loading)
        XCTAssertEqual(loginUseCase.executeCallCount, 0)
    }
    
    func testInvalidEmailShowsValidationError() {
        sut.identifier = "username@gmail$com"
        sut.password = "password"
        
        sut.signin()
        
        XCTAssertEqual(sut.identifierError, "Enter a valid email")
        XCTAssertNotEqual(sut.formState, .loading)
        XCTAssertEqual(loginUseCase.executeCallCount, 0)
    }
    
    func testEmptyPasswordShowsValidationError() {
        sut.identifier = "username@gmail.com"
        sut.password = ""
        
        sut.signin()
        
        XCTAssertEqual(sut.passwordError, "Enter Password.")
        XCTAssertNotEqual(sut.formState, .loading)
        XCTAssertEqual(loginUseCase.executeCallCount, 0)
    }
    
    func testValidCredsReturnSuccess() {
        let expectation = expectation(description: "Signin should succeed")
        sut.identifier = "username@gmail.com"
        sut.password = "password"
        
        let session = testAuthSession(testUser())
        
        cancellable = sut.$formState
            .dropFirst()
            .sink { state in
                if state == .success {
                    expectation.fulfill()
                }
            }
        
        sut.signin()
        loginUseCase.sendSuccess(session)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertNil(sut.identifierError)
        XCTAssertNil(sut.passwordError)
        XCTAssertEqual(sut.session, session)
        XCTAssertEqual(loginUseCase.executeCallCount, 1)
        
        cancellable?.cancel()
    }
    
    func testLoginFailsReturnFailure() {
        let expectation = expectation(description: "Signin should fail")
        sut.identifier = "username@gmail.com"
        sut.password = "password"
        
        cancellable = sut.$formState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    expectation.fulfill()
                    XCTAssertEqual(error, AuthError.invalidCredentials.localizedDescription)
                }
            }
        
        sut.signin()
        loginUseCase.sendFailure(.invalidCredentials)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertNil(sut.identifierError)
        XCTAssertNil(sut.passwordError)
        XCTAssertNil(sut.session)
        XCTAssertEqual(loginUseCase.executeCallCount, 1)
        
        cancellable?.cancel()
    }
    
    func testDuplicateLoginIsPrevented() {
        sut.identifier = "username@gmail.com"
        sut.password = "password"
        
        sut.signin()
        
        XCTAssertEqual(sut.formState, .loading)
        
        sut.signin()
    
        XCTAssertEqual(loginUseCase.executeCallCount, 1)
    }
    
    func testCancelLoginResetsLoadingState() {
        sut.identifier = "username@gmail.com"
        sut.password = "password"
        
        sut.signin()
        
        XCTAssertEqual(sut.formState, .loading)
        
        sut.cancelLogin()
    
        XCTAssertEqual(sut.formState, .idle)
        XCTAssertNil(sut.session)
        XCTAssertTrue(loginUseCase.isCancelled)
        XCTAssertEqual(loginUseCase.executeCallCount, 1)
    }
}
