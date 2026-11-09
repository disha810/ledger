//
//  MockKeychainService.swift
//  Ledger
//
//  Created by Divya on 02/11/26.
//

import Foundation

final class MockKeychainService: KeychainService {

    private var storage: [String: Data] = [:]
    var errorToThrow: KeychainError?

    func save(_ data: Data, forKey key: String) throws {
        if let errorToThrow {
            throw errorToThrow
        }
        
        storage[key] = data
    }

    func retrieve(forKey key: String) throws -> Data? {
        if let errorToThrow {
            throw errorToThrow
        }
        
        return storage[key]
    }

    func delete(forKey key: String) throws {
        if let errorToThrow {
            throw errorToThrow
        }
        
        storage.removeValue(forKey: key)
    }
    
    func emptyStorage() {
        storage.removeAll()
    }
}
