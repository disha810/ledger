//
//  SessionRepositoryImpl.swift
//  Ledger
//
//  Created by Divya on 02/11/26.
//

import Combine
import Foundation

final class SessionRepositoryImpl: SessionRepository {
    let keychainService: KeychainService
    let encoder: JSONEncoder
    let decoder: JSONDecoder
    
    private let sessionKey = "auth_session"
    
    init(keychainService: KeychainService,
         encoder: JSONEncoder,
         decoder: JSONDecoder) {
        self.keychainService = keychainService
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func save(_ session: AuthSession) -> AnyPublisher<Void, SessionError> {
        perform {
            let data = try self.encoder.encode(session)
            
            try self.keychainService.save(data, forKey: self.sessionKey)
        }
    }
    
    func getSession() -> AnyPublisher<AuthSession?, SessionError> {
        perform {
            guard let data = try self.keychainService.retrieve(forKey: self.sessionKey) else {
                return nil
            }
            
            return try self.decoder.decode(AuthSession.self, from: data)
        }
    }
    
    func clearSession() -> AnyPublisher<Void, SessionError> {
        perform {
            try self.keychainService.delete(forKey: self.sessionKey)
        }
    }
    
    
    private func perform<Output>(_ operation: @escaping () throws -> Output)
        -> AnyPublisher<Output, SessionError> {
            Deferred {
                let result: Result<Output, SessionError>
                
                do {
                    result = .success(try operation())
                } catch {
                    result = .failure(Self.mapError(error))
                }
                
                return result.publisher
            }
            .eraseToAnyPublisher()
    }
    
    private static func mapError(_ error: Error) -> SessionError {
        if error is EncodingError {
            return .encodingFailure
        }
        
        if error is DecodingError {
            return .decodingFailure
        }
        
        if error is KeychainError {
            return .storageFailure
        }
        
        return .unknown
    }
}
