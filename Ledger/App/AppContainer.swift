//
//  AppContainer.swift
//  Ledger
//
//  Created by Divya on 31/10/26.
//

import Foundation

@MainActor
final class AppContainer {
    let authCoordinator: AuthCoordinator
    let loginUseCase: LoginUseCase
    let signupUseCase: SignupUseCase
    let logoutUseCase: LogoutUseCase
    
    init() {
        let mockDataSource = MockDataSource()
        let authRepository = AuthRepositoryImpl(dataSource: mockDataSource)
        let keychainService = KeychainServiceImpl()
        let sessionRepository = SessionRepositoryImpl(keychainService: keychainService,
                                                       encoder: JSONEncoder(),
                                                       decoder: JSONDecoder())
        
        self.authCoordinator = AuthCoordinator(sessionRepository: sessionRepository)
        
        self.loginUseCase = LoginUseCase(authRepository: authRepository,
                                         sessionRepository: sessionRepository)
        self.signupUseCase = SignupUseCase(authRepository: authRepository,
                                           sessionRepository: sessionRepository)
        self.logoutUseCase = LogoutUseCase(authRepository: authRepository,
                                           sessionRepository: sessionRepository)
    }
}
