//
//  User.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/9/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

struct Friend: JSONSerializable {

    let name: String

    var json: JSONDictionary {
        return ["name" : name]
    }

}

extension Friend: JSONDeserializable{

    init(json: JSONDictionary) throws {
        name = try json.decode(key: "name")
    }

}

struct User: JSONSerializable {

    let name: String
    let age: Int
    let date: Date
    let friend: Friend

    var json: JSONDictionary {
        return [
            "name" : name,
            "age" : age,
            "date" : date,
            "friend" : friend
        ]
    }

}

extension User: JSONDeserializable {

    init(json: JSONDictionary) throws {
        name = try json.decode(key: "name")
        age = try json.decode(key: "age")
        date = try json.decode(key: "date")
        friend = try json.decode(key: "friend")
    }
    
}
