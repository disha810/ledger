//
//  AuthCoordinator.swift
//  Ledger
//
//  Created by Divya on 07/11/26.
//

import Combine
import Foundation

@MainActor
protocol AuthenticationStateManaging {
    func authenticate(with session: AuthSession)
}

enum AuthState: Equatable {
    case checkingSession
    case authenticated(session: AuthSession)
    case unauthenticated
    case sessionError
}

@MainActor
final class AuthCoordinator: ObservableObject, AuthenticationStateManaging {
    @Published var authState: AuthState = .checkingSession
    
    private let sessionRepository: SessionRepository
    
    private var restoreCancellable:AnyCancellable?
    
    init(sessionRepository: SessionRepository) {
        self.sessionRepository = sessionRepository
    }
    
    func restoreSession() {
        restoreCancellable?.cancel()
        
        self.authState = .checkingSession
        
        restoreCancellable = self.sessionRepository.getSession()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    if self?.authState == .checkingSession {
                        self?.authState = .sessionError
                    }
                case .failure(let error):
                    self?.authState = .sessionError
                }
                
            }, receiveValue: {[weak self] result in
                if let result {
                    self?.authState = .authenticated(session: result)
                } else {
                    self?.authState = .unauthenticated
                }
            })
    }
    
    func authenticate(with session: AuthSession) {
        restoreCancellable?.cancel()
        self.authState = .authenticated(session: session)
    }
    
    func logout() {
        restoreCancellable?.cancel()
        
        self.authState = .unauthenticated
    }
}
