//
//  LoginRequest.swift
//  TinyApiClientExample
//
//  Created by Daniel Lozano Valdés on 11/30/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import Foundation
import TinyAPIClient

public struct LoginRequest: JSONSerializable {

    let email: String
    let password: String

    public var json: JSONDictionary {
        return ["email" : email,
                "password" : password]
    }
    
}
