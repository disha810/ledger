//
//  AuthSessionDTO.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

struct AuthSessionDTO: Decodable {
    let user: UserDTO
    let accessToken: String
}
