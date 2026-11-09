//
//  KeychainService.swift
//  Ledger
//
//  Created by Divya on 02/11/26.
//

import Foundation

protocol KeychainService {
    func save(_ data: Data, forKey: String) throws
    func retrieve(forKey: String) throws -> Data?
    func delete(forKey: String) throws
}
