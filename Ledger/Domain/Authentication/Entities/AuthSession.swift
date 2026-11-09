//
//  AuthSession.swift
//  Ledger
//
//  Created by Divya on 31/10/26.
//

struct AuthSession: Codable, Equatable, Hashable {
    let user: User
    let accessToken: String
}
