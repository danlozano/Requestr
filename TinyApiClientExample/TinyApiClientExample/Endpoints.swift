//
//  Endpoints.swift
//  TinyApiClientExample
//
//  Created by Daniel Lozano Valdés on 11/30/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import Foundation

enum Endpoints {

    static let baseURL = "https://remotelyapi.herokuapp.com"

    case login
    case me
    case user(userId: Int)
    case users

    var fullPath: String {
        let path: String
        switch self {
        case .login:
            path = "/login"
        case .me:
            path = "/api/me"
        case .user(let userId):
            path = "/api/users/\(userId)"
        case .users:
            path = "/api/users"
        }
        return Endpoints.baseURL + path
    }

    var rootKey: String? {
        switch self {
        case .login:
            return nil
        case .me:
            return nil
        case .user(_):
            return nil
        case .users:
            return "users"
        }
    }
    
}
