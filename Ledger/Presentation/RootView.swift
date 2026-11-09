//
//  RootView.swift
//  Ledger
//
//  Created by Divya on 07/11/26.
//

import SwiftUI

struct RootView: View {
    @ObservedObject private var authCoordinator: AuthCoordinator
    
    let signupUseCase: SignupUseCaseProtocol
    let loginUseCase: LoginUseCaseProtocol
    let logoutUseCase: LogoutUseCaseProtocol
    
    init(authCoordinator: AuthCoordinator,
         signupUseCase: SignupUseCaseProtocol,
         loginUseCase: LoginUseCaseProtocol,
         logoutUseCase: LogoutUseCaseProtocol) {
        _authCoordinator = ObservedObject(wrappedValue: authCoordinator)
        self.signupUseCase = signupUseCase
        self.loginUseCase = loginUseCase
        self.logoutUseCase = logoutUseCase
    }
    
    var body: some View {
        Group {
            switch authCoordinator.authState {
            case .checkingSession:
                ProgressView()
            case .authenticated(let session):
                MainAppView(session: session,
                            logoutUseCase: logoutUseCase,
                            authCoordinator: authCoordinator)
            case .unauthenticated:
                AuthflowView(signupUseCase: signupUseCase,
                             loginUseCase: loginUseCase,
                             authCoordinator: authCoordinator)
            case .sessionError:
                SessionErrorView {
                    authCoordinator.restoreSession()
                }
            }
        }
        .task {
            authCoordinator.restoreSession()
        }
    }
}

//#Preview {
//    RootView(authCoordinator: AuthCoordinator(sessionRepository:
//                                                SessionRepositoryImpl(keychainService: KeychainServiceImpl(),
//                                                                                       encoder: JSONEncoder(),
//                                                                                       decoder: JSONDecoder())))
//}

struct SessionErrorView: View {
    let restore: () -> Void
    
    init(_ restore: @escaping () -> Void) {
        self.restore = restore
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Unable to restore session")
                .font(.title2)
            
            Text("Please try again!")
            
            Button("Retry") {
                restore()
            }
        }
        .padding()
    }
}
