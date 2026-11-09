//
//  KeyChainError.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

import Foundation

enum KeychainError: Error, Equatable {
    case unexpectedStatus(OSStatus)
}
