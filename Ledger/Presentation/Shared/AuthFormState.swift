//
//  AuthFormState.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

enum AuthFormState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
}
