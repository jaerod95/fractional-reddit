//
//  AccessToken.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation

struct AccessToken: Codable {
    var accessToken: String
    var tokenType: String
    var expiresIn: Int
    var scope: String
    var createdAt: Date = Date()
    
    var isExpired: Bool {
        // TODO: add expiration here
        return false
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope
    }
}
