//
//  SessionError.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

enum SessionError: Error, Equatable {
    case storageFailure
    case encodingFailure
    case decodingFailure
    case unknown
}
