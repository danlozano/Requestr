//
//  SignupRequest.swift
//  TinyApiClientExample
//
//  Created by Daniel Lozano Valdés on 12/8/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import Foundation
import TinyAPIClient

public struct SignupRequest: JSONSerializable {

    let name: String
    let email: String
    let password: String

    public var json: JSONDictionary {
        return ["name" : name,
                "email" : email,
                "password" : password]
    }

}
