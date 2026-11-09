//
//  LoginViewModel.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

import Combine
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var identifier: String = ""
    @Published var password: String = ""
    
    @Published private(set) var formState: AuthFormState = .idle
    @Published private(set) var identifierError: String?
    @Published private(set) var passwordError: String?
    
    private let loginUseCase: LoginUseCaseProtocol
    private let authenticationManager: AuthenticationStateManaging
    
    private var didReceiveSession = false
    
    private var loginCancellable: AnyCancellable?
    private var validationCancellables = Set<AnyCancellable>()
    
    init(loginUseCase: LoginUseCaseProtocol,
         authenticationManager: AuthenticationStateManaging) {
        self.loginUseCase = loginUseCase
        self.authenticationManager = authenticationManager
        bindValidation()
    }
    
    private func bindValidation() {
        $identifier
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .map { value in
                let value = value.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

                guard !value.isEmpty else {
                    return "Enter your email or username."
                }
                
                if value.contains("@") {
                    return AuthValidator.validateEmail(value)
                }
                 
                return AuthValidator.validateUsername(value)
            }
            .sink { [weak self] result in
                self?.identifierError = result
            }
            .store(in: &validationCancellables)
        
        $password
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .map { value in
                guard !value.isEmpty else {
                    return "Enter your password."
                }
                
                return nil
            }
            .sink { [weak self] result in
                self?.passwordError = result
            }
            .store(in: &validationCancellables)
    }
    
    func signin() {
        guard formState != .loading else {
            return
        }
        
        let normalizedIdentifier = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if normalizedIdentifier.isEmpty {
            identifierError = "Enter Username or Email"
        } else if normalizedIdentifier.contains("@") {
            identifierError = AuthValidator.validateEmail(normalizedIdentifier)
        } else {
            identifierError = AuthValidator.validateUsername(normalizedIdentifier)
        }
        
        guard !password.isEmpty else {
            passwordError = "Enter Password."
            return
        }
        
        guard identifierError == nil &&
                passwordError == nil else {
            return
        }
        
        self.formState = .loading
        didReceiveSession = false
        
        loginCancellable = loginUseCase.execute(identifier: identifier,
                                                password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else {
                    return
                }
                
                if !self.didReceiveSession {
                    self.formState = .failure("Login failed, please try again!!")
                }
                
                if case .failure(let error) = completion {
                    self.formState = .failure(error.localizedDescription)
                }
                
            }, receiveValue: { [weak self] session in
                self?.didReceiveSession = true
                self?.authenticationManager.authenticate(with: session)
                self?.formState = .success
            })
    }
    
    func cancelLogin() {
        loginCancellable?.cancel()
        loginCancellable = nil
        
        if formState == .loading {
            formState = .idle
        }
    }
}
