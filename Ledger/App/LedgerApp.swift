//
//  LedgerApp.swift
//  Ledger
//
//  Created by Divya on 31/10/26.
//

import SwiftUI

@main
struct LedgerApp: App {
    @State private var appContainer = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            RootView(authCoordinator: appContainer.authCoordinator,
                     signupUseCase: appContainer.signupUseCase,
                     loginUseCase: appContainer.loginUseCase,
                     logoutUseCase: appContainer.logoutUseCase)
        }
    }
}
