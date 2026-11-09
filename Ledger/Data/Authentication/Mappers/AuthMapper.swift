//
//  AuthMapper.swift
//  Ledger
//
//  Created by Divya on 01/11/26.
//

struct AuthMapper {
    static func map(_ userDTO: UserDTO) -> User {
        User(id: userDTO.id,
             name: userDTO.name,
             email: userDTO.email,
             username: userDTO.username)
    }
    
    static func map(_ authSessionDTO: AuthSessionDTO) -> AuthSession {
        AuthSession(user: map(authSessionDTO.user),
                    accessToken: authSessionDTO.accessToken)
    }
}
