//
//  SignupView.swift
//  Ledger
//
//  Created by Divya on 06/11/26.
//

import SwiftUI

struct SignupView: View {
    
    @ObservedObject private var viewmodel: SignupViewModel
    
    let onLogin: () -> Void
    
    private var isLoading: Bool {
        viewmodel.formState == .loading
    }
    
    init(viewmodel: SignupViewModel,
         onLogin: @escaping () -> Void) {
        _viewmodel = ObservedObject(wrappedValue: viewmodel)
        self.onLogin = onLogin
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text("Ledger")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.green.gradient)
                    .fontDesign(.serif)
                
                Text("Create an Account")
                    .font(.title2)
                    .fontDesign(.rounded)
                
                HStack {
                    Text("Already have an account?")
                        .font(.caption)
                    
                    Button {
                        onLogin()
                    } label: {
                        Text("Sign in")
                            .font(.caption)
                    }
                }
                
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Full Name", text: $viewmodel.name)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.words)
                        .textContentType(.name)
                        .submitLabel(.next)
                        .padding()
                        .background(.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    if let nameError = viewmodel.nameError {
                        Text(nameError)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Email", text: $viewmodel.email)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                        .submitLabel(.next)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    if let emailError = viewmodel.emailError {
                        Text(emailError)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Username", text: $viewmodel.username)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .textContentType(.username)
                        .submitLabel(.next)
                        .padding()
                        .background(.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    if let usernameError = viewmodel.usernameError {
                        Text(usernameError)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    SecureField("Password", text: $viewmodel.password)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .textContentType(.newPassword)
                        .padding()
                        .background(.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    if let passwordError = viewmodel.passwordError {
                        Text(passwordError)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    SecureField("Confirm Password", text: $viewmodel.confirmPassword)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .textContentType(.newPassword)
                        .padding()
                        .background(.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    if let confirmPasswordError = viewmodel.confirmPasswordError {
                        Text(confirmPasswordError)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.red)
                    }
                }
                
                
                if case .failure(let error) = viewmodel.formState {
                    Text(error)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.red)
                }
                
                Button {
                    viewmodel.signup()
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Signup")
                                .foregroundStyle(.white)
                                .font(.title2.bold())
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(isLoading)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

//#Preview {
//    SignupView(viewmodel: SignupViewModel(signupUseCase: SignupUseCase(repository: AuthRepositoryImpl(dataSource: MockDataSource()))), onSignIn: {})
//}
