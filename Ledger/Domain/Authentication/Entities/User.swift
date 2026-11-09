//
//  User.swift
//  Ledger
//
//  Created by Divya on 31/10/26.
//

struct User: Identifiable, Equatable, Codable, Hashable {
    let id: String
    let name: String
    let email: String
    let username: String
}
