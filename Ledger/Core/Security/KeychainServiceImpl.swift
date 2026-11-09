//
//  KeychainServiceImpl.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

import Combine
import Foundation

final class KeychainServiceImpl: KeychainService {
    let service = "com.ledger.auth"
    
    func save(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let attrs: [String: Any] = [
            kSecValueData as String: data
        ]
        
        var status = SecItemUpdate(query as CFDictionary,
                                   attrs as CFDictionary)
        
        if status == errSecDuplicateItem {
            var newQuery = query
            newQuery[kSecValueData as String] = data
            
            status = SecItemAdd(newQuery as CFDictionary, nil)
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func retrieve(forKey key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: CFTypeRef?
        
        let status = SecItemCopyMatching(query as CFDictionary,
                                         &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.unexpectedStatus(errSecInternalError)
        }
        
        return data
    }
    
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecItemNotFound ||
            status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
