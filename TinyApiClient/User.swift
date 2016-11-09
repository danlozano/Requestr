//
//  User.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/9/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

struct User {

    let name: String
    let age: Int

}

extension User: JSONDeserializable {

    init(json: JSONDictionary) throws {
        name = try JSON.decode(json, key: "name")
        age = try JSON.decode(json, key: "age")
    }

}
