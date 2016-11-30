//
//  User.swift
//  TinyApiClientExample
//
//  Created by Daniel Lozano Valdés on 11/30/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import Foundation
import TinyApiClient

public struct User {

    let id: String
    let email: String
    let name: String

}

extension User: JSONDeserializable, JSONSerializable {

    public var json: JSONDictionary {
        return ["email" : email,
                "name" : name]
    }

    public init(json: JSONDictionary) throws {
        id = try json.decode("id")
        email = try json.decode("email")
        name = try json.decode("name")
    }
    
}
