//
//  SessionRepository.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

import Combine

protocol SessionRepository {
    func save(_ session: AuthSession) -> AnyPublisher<Void, SessionError>
    func getSession() -> AnyPublisher<AuthSession?, SessionError>
    func clearSession() -> AnyPublisher<Void, SessionError>
}
