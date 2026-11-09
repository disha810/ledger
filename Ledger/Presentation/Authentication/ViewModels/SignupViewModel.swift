//
//  SignupViewModel.swift
//  Ledger
//
//  Created by Divya on 05/11/26.
//

import Combine
import Foundation

@MainActor
final class SignupViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var nameError: String?
    @Published var emailError: String?
    @Published var usernameError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    
    @Published private(set) var formState: AuthFormState = .idle
    
    private let signupUseCase: SignupUseCaseProtocol
    private let authenticationManager: AuthenticationStateManaging
    
    private var didReceiveSession = false
    
    private var signupCancellable: AnyCancellable?
    private var validationCancellables = Set<AnyCancellable>()
    
    init(signupUseCase: SignupUseCaseProtocol,
         authenticationManager: AuthenticationStateManaging) {
        self.signupUseCase = signupUseCase
        self.authenticationManager = authenticationManager
        bindValidation()
    }
    
    func signup() {
        guard formState != .loading else {
            return
        }
        
        nameError = validateName(name)
        emailError = validateEmail(email)
        usernameError = validateUsername(username)
        passwordError = validatePassword(password)
        confirmPasswordError = validateConfirmPassword(password,
                                                       confirmPassword: confirmPassword)
        
        guard nameError == nil &&
                emailError == nil &&
                usernameError == nil &&
                passwordError == nil &&
                confirmPasswordError == nil else {
            return
        }
        
        didReceiveSession = false
        self.formState = .loading
        
        signupCancellable = signupUseCase
                .execute(name: name,
                         email: email,
                         username: username,
                         password: password)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    if !self.didReceiveSession {
                        self.formState = .failure("Signup failed, please try again!!")
                    }
                    
                    if case .failure(let error) = completion {
                        self.formState = .failure(error.localizedDescription)
                    }
                }, receiveValue: { [weak self] session in
                    guard let self else { return }
                    self.didReceiveSession = true
                    self.formState = .success
                    self.authenticationManager.authenticate(with: session)
                })
    }
    
    func cancelSignup() {
        signupCancellable?.cancel()
        signupCancellable = nil
        
        if formState == .loading {
            formState = .idle
        }
    }
    
    private func bindValidation() {
        $username
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .map { [weak self] value in
                self?.validateUsername(value)
            }
            .sink { [weak self] result in
                self?.usernameError = result
            }
            .store(in: &validationCancellables)
        
        $email
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .map { [weak self] value in
                self?.validateEmail(value)
            }
            .sink { [weak self] result in
                self?.emailError = result
            }
            .store(in: &validationCancellables)
        
        $password
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .map { [weak self] value in
                self?.validatePassword(value)
            }
            .sink { [weak self] result in
                self?.passwordError = result
            }
            .store(in: &validationCancellables)
        
        Publishers.CombineLatest($password, $confirmPassword)
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .map { [weak self] (passsword, confirmPassword) in
                self?.validateConfirmPassword(passsword,
                                             confirmPassword: confirmPassword)
            }
            .sink { [weak self] result in
                self?.confirmPasswordError = result
            }
            .store(in: &validationCancellables)
    }
    
    private func validateName(_ value: String) -> String? {
        let value = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !value.isEmpty else {
            return "Enter your name."
        }
        
        return nil
    }
    
    private func validateUsername(_ value: String) -> String? {
        let value = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !value.isEmpty else {
            return "Enter your username."
        }
        
        return AuthValidator.validateUsername(value)
    }
    
    private func validateEmail(_ value: String) -> String? {
        let value = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !value.isEmpty else {
            return "Enter your email."
        }
        
        return AuthValidator.validateEmail(value)
    }
    
    private func validatePassword(_ value: String) -> String? {
        guard !value.isEmpty else {
            return "Enter your password."
        }
        
        return AuthValidator.validatePassword(value)
    }
    
    private func validateConfirmPassword(_ password: String,
                                         confirmPassword: String) -> String? {
        guard !confirmPassword.isEmpty else {
            return "Confirm your password."
        }
        
        guard password == confirmPassword else {
            return "Confirm password doesn't match"
        }
        
        return nil
    }
}
