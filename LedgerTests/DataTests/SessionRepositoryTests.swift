//
//  SessionRepositoryTests.swift
//  Ledger
//
//  Created by Divya on 02/11/26.
//

import XCTest
import Combine
import Security
@testable import Ledger

final class SessionRepositoryTests: XCTestCase {
    
    var mockKeychainService: MockKeychainService!
    var sessionRepository: SessionRepository!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        self.mockKeychainService = MockKeychainService()
        self.sessionRepository = SessionRepositoryImpl(keychainService: mockKeychainService,                                                  encoder: JSONEncoder(),
                                                       decoder: JSONDecoder())
        self.cancellables = []
    }
    
    override func tearDown() {
        self.mockKeychainService = nil
        self.sessionRepository = nil
        self.cancellables = nil
        super.tearDown()
    }
    
    func testSaveAndRetrieveSession() {
        // Arrange
        let authSession = testAuthSession(testUser())
        
        let saveExpectation = expectation(description: "session should be saved")
        let getSessionExpectation = expectation(description: "session should be retrieved")

        // Act
        // save
        sessionRepository.save(authSession)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    saveExpectation.fulfill()
                case .failure(_):
                    XCTFail("save session should not fail")
                }
            }, receiveValue: {
                
            })
            .store(in: &cancellables)
        
        wait(for: [saveExpectation], timeout: 1)
        
        // getSession
        sessionRepository.getSession()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    getSessionExpectation.fulfill()
                case .failure(let error):
                    XCTFail("getSession should not fail \(error.localizedDescription)")
                }
            }, receiveValue: { result in
                XCTAssertEqual(authSession, result)
            })
            .store(in: &cancellables)

        // Assert
        wait(for: [getSessionExpectation], timeout: 1)
    }
    
    func testSaveSessionWhenKeychainFails() {
        // Arrange
        let authSession = testAuthSession(testUser())
        
        let saveExpectation = expectation(description: "session should not be saved")

        // Act
        
        mockKeychainService.errorToThrow = KeychainError.unexpectedStatus(errSecParam)
        // save
        sessionRepository.save(authSession)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("save session should not success")
                case .failure(let error):
                    XCTAssertEqual(error, SessionError.storageFailure)
                    saveExpectation.fulfill()
                }
            }, receiveValue: {
                
            })
            .store(in: &cancellables)
        
        wait(for: [saveExpectation], timeout: 1)
    }
    
    func testGetSessionWhenNoSessionExists() {
        let getSessionExpectation = expectation(description: "getSession should succeed")

        // Act
        mockKeychainService.emptyStorage()

        sessionRepository.getSession()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    XCTFail("getSession should not fail")
                }
            }, receiveValue: { result in
                XCTAssertNil(result)
                getSessionExpectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [getSessionExpectation], timeout: 1)
    }
    
    func testClearSession() {
        let clearSessionExpectation = expectation(description: "clearSession should succeed")
        let getSessionExpectation = expectation(description: "getSession should succeed")
        
        // Act
        sessionRepository.clearSession()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    clearSessionExpectation.fulfill()
                case .failure(_):
                    XCTFail("clearSession should not fail")
                }
            }, receiveValue: {
            })
            .store(in: &cancellables)
        
        sessionRepository.getSession()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    getSessionExpectation.fulfill()
                case .failure(_):
                    XCTFail("getSession should not fail")
                }
            }, receiveValue: { result in
                XCTAssertNil(result)
            })
            .store(in: &cancellables)
        
        wait(for: [getSessionExpectation], timeout: 1)
        
        wait(for: [clearSessionExpectation], timeout: 1)
    }
    
    func testGetSessionWhenKeychainFails() {
        let getSessionExpectation = expectation(description: "getSession should fail")

        // Act
        mockKeychainService.errorToThrow = KeychainError.unexpectedStatus(errSecParam)
        
        sessionRepository.getSession()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("getSession should not succeed")
                case .failure(let error):
                    XCTAssertEqual(error, SessionError.storageFailure)
                    getSessionExpectation.fulfill()
                }
            }, receiveValue: { result in
                XCTFail("getSession should not succeed")
            })
            .store(in: &cancellables)
        
        wait(for: [getSessionExpectation], timeout: 1)
    }
}

func testUser() -> User {
    User(id: UUID().uuidString,
        name: "test user",
        email: "testuser@gmail.com",
        username: "testuser")
}

func testAuthSession(_ user: User) -> AuthSession {
    AuthSession(user: user,
                accessToken: UUID().uuidString)
}
