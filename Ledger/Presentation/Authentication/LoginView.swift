//
//  LoginView.swift
//  Ledger
//
//  Created by Divya on 06/11/26.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private var viewmodel: LoginViewModel
    
    let onSignup: () -> Void
    
    private var isLoading: Bool {
        viewmodel.formState == .loading
    }
    
    init(viewmodel: LoginViewModel, onSignup: @escaping () -> Void) {
        _viewmodel = ObservedObject(wrappedValue: viewmodel)
        self.onSignup = onSignup
    }
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .center, spacing: 20) {
                Text("Ledger")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.green.gradient)
                    .fontDesign(.serif)
                
                Text("Login")
                    .font(.title2)
                    .fontDesign(.rounded)
                
                HStack {
                    Text("Don't have an account?")
                        .font(.caption)
                    
                    Button {
                        onSignup()
                    } label: {
                        Text("Sign up")
                            .font(.caption)
                    }
                }
                
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Email or Username", text: $viewmodel.identifier)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(.gray.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    if let identifierError = viewmodel.identifierError {
                        Text(identifierError)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    SecureField("Password", text: $viewmodel.password)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .textContentType(.password)
                        .submitLabel(.go)
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
                
                if case .failure(let error) = viewmodel.formState {
                    Text(error)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.red)
                }
                
                Button {
                    viewmodel.signin()
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Signin")
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
//    LoginView(viewmodel: LoginViewModel(loginUseCase: LoginUseCase(authRepository: AuthRepositoryImpl(dataSource: MockDataSource()), sessionRepository: SessionRepositoryImpl(keychainService: KeychainServiceImpl(), encoder: JSONEncoder(), decoder: JSONDecoder()))),
//    onSignup: {})
//}
