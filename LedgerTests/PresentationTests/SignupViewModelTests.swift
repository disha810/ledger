//
//  SignupViewModelTests.swift
//  Ledger
//
//  Created by Divya on 06/11/26.
//

import XCTest
import Combine
@testable import Ledger

@MainActor
final class SignupViewModelTests: XCTestCase {
    
    var signupUseCase: MockSignupUseCase!
    var sut: SignupViewModel!
    var cancellable: AnyCancellable?
    
    override func setUp() {
        super.setUp()
        
        signupUseCase = MockSignupUseCase()
        sut = SignupViewModel(signupUseCase: signupUseCase)
    }

    override func tearDown() {
        cancellable?.cancel()
        cancellable = nil
        signupUseCase = nil
        sut = nil
        
        super.tearDown()
    }
    
    func testEmptyFormShowsValidationError() {
        sut.name = ""
        sut.email = ""
        sut.username = ""
        sut.password = ""
        sut.confirmPassword = ""
        
        sut.signup()
        
        XCTAssertEqual(sut.usernameError, "Enter your username.")
        XCTAssertEqual(sut.emailError, "Enter your email.")
        XCTAssertEqual(sut.passwordError, "Enter your password.")
        XCTAssertEqual(sut.confirmPasswordError, "Confirm your password.")
        XCTAssertNotEqual(sut.formState, .loading)
        XCTAssertEqual(signupUseCase.executeCallCount, 0)
    }
    
    func testValidFormCallsUseCase() {
        sut.name = "name"
        sut.username = "username"
        sut.email = "username@gmail.com"
        sut.password = "password"
        sut.confirmPassword = "password"
        
        sut.signup()
        
        XCTAssertEqual(sut.name, signupUseCase.receivedName)
        XCTAssertEqual(sut.username, signupUseCase.receivedUserName)
        XCTAssertEqual(sut.email, signupUseCase.receivedEmail)
        XCTAssertEqual(sut.password, signupUseCase.receivedPassword)
        XCTAssertEqual(sut.formState, .loading)
        XCTAssertEqual(signupUseCase.executeCallCount, 1)
    }
    
    func testValidCredsReturnSuccess() {
        let expectation = expectation(description: "Signup should succeed")
        sut.name = "name"
        sut.username = "username"
        sut.email = "username@gmail.com"
        sut.password = "password"
        sut.confirmPassword = "password"
        
        let session = testAuthSession(testUser())
        
        cancellable = sut.$formState
            .dropFirst()
            .sink { state in
                if state == .success {
                    expectation.fulfill()
                }
            }
        
        sut.signup()
        signupUseCase.sendSuccess(session)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(signupUseCase.executeCallCount, 1)
        XCTAssertEqual(sut.formState, .success)
        XCTAssertEqual(sut.session, session)
        
        cancellable?.cancel()
    }
    
    func testSignupFailsReturnFailure() {
        let expectation = expectation(description: "Signin should fail")
        sut.name = "name"
        sut.username = "username"
        sut.email = "username@gmail.com"
        sut.password = "password"
        sut.confirmPassword = "password"
        
        cancellable = sut.$formState
            .dropFirst()
            .sink { state in
                if case .failure(let error) = state {
                    expectation.fulfill()
                    XCTAssertEqual(error, AuthError.invalidCredentials.localizedDescription)
                }
            }
        
        sut.signup()
        signupUseCase.sendFailure(.invalidCredentials)
        
        wait(for: [expectation], timeout: 1)
    
        XCTAssertNil(sut.session)
        XCTAssertEqual(signupUseCase.executeCallCount, 1)
        
        cancellable?.cancel()
    }
    
    func testDuplicateSignupIsPrevented() {
        sut.name = "name"
        sut.username = "username"
        sut.email = "username@gmail.com"
        sut.password = "password"
        sut.confirmPassword = "password"
        
        sut.signup()
        
        XCTAssertEqual(sut.formState, .loading)
        
        sut.signup()
    
        XCTAssertEqual(signupUseCase.executeCallCount, 1)
    }
    
    func testCancelLoginResetsLoadingState() {
        sut.name = "name"
        sut.username = "username"
        sut.email = "username@gmail.com"
        sut.password = "password"
        sut.confirmPassword = "password"
        
        sut.signup()
        
        XCTAssertEqual(sut.formState, .loading)
        
        sut.cancelSignup()
    
        XCTAssertEqual(sut.formState, .idle)
        XCTAssertNil(sut.session)
        XCTAssertTrue(signupUseCase.isCancelled)
        XCTAssertEqual(signupUseCase.executeCallCount, 1)
    }
}
