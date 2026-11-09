//
//  MainAppView.swift
//  Ledger
//
//  Created by Divya on 07/11/26.
//

import SwiftUI

struct MainAppView: View {
    let session: AuthSession
    
    private let logoutUseCase: LogoutUseCaseProtocol
    private let authCoordinator: AuthCoordinator
    
    @State private var logoutError: String?
    @State private var isLoggingout = false
    
    init(session: AuthSession,
         logoutUseCase: LogoutUseCaseProtocol,
         authCoordinator: AuthCoordinator) {
        self.session = session
        self.logoutUseCase = logoutUseCase
        self.authCoordinator = authCoordinator
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome, \(session.user.name)")

            Text(session.user.email)
            
            Button {
                logout()
            } label: {
                if isLoggingout {
                    ProgressView()
                } else {
                    Text("Logout")
                }
            }
            .disabled(isLoggingout)
            .alert("Logout Failes",
                   isPresented: Binding(get: { logoutError != nil },
                                        set: { if !$0 { logoutError = nil } }
                                       )
                   ) {
                Button("OK", role: .cancel) {
                    logoutError = nil
                }
            } message: {
                Text(logoutError ?? "")
            }
        }
    }
    
    
    private func logout() {
        guard !isLoggingout else { return }
        
        isLoggingout = true
        logoutError = nil
        
        logoutUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isLoggingout = false
                if case .failure(let error) = completion {
                    if case AuthError.clearSessionFailed = error {
                        authCoordinator.logout()
                    }
                    logoutError = error.localizedDescription
                }
            }, receiveValue: { _ in
                authCoordinator.logout()
            })
    }
}

//#Preview {
//    MainAppView()
//}
