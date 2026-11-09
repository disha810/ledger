//
//  AuthflowView.swift
//  Ledger
//
//  Created by Divya on 06/11/26.
//

import SwiftUI

enum AuthRoute {
    case signup
    case login
}

struct AuthflowView: View {
    @StateObject private var signupViewModel: SignupViewModel
    @StateObject private var loginViewModel: LoginViewModel
    @State private var route: AuthRoute = .signup
    
    init(signupUseCase: SignupUseCaseProtocol,
         loginUseCase: LoginUseCaseProtocol,
         authCoordinator: AuthenticationStateManaging) {
        _signupViewModel = StateObject(wrappedValue: SignupViewModel(signupUseCase: signupUseCase,
                            authenticationManager: authCoordinator))
        _loginViewModel = StateObject(wrappedValue: LoginViewModel(loginUseCase: loginUseCase, authenticationManager: authCoordinator))
    }
    
    var body: some View {
        Group {
            switch route {
            case .signup:
                SignupView(viewmodel: signupViewModel,
                           onLogin: showLogin)
            case .login:
                LoginView(viewmodel: loginViewModel,
                          onSignup: showSignup)
            }
        }
    }
    
    private func showSignup() {
        route = .signup
    }
    
    private func showLogin() {
        route = .login
    }
}

//#Preview {
//    AuthflowView(signupUseCase: SignupUseCase(repository: AuthRepositoryImpl(dataSource: MockDataSource())),
//                 loginUseCase: LoginUseCase(authRepository: AuthRepositoryImpl(dataSource: MockDataSource()), sessionRepository: SessionRepositoryImpl(keychainService: KeychainServiceImpl(), encoder: JSONEncoder(), decoder: JSONDecoder())))
//}
