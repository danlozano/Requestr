//
//  User.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/9/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

public struct User: JSONSerializable {

    public let name: String
    public let age: Int
    public let date: Date

    public var json: JSONDictionary {
        return [
            "name" : name,
            "age" : age,
            "date" : date
        ]
    }

    public init(name: String, age: Int, date: Date) {
        self.name = name
        self.age = age
        self.date = date
    }

}

extension User: JSONDeserializable {

    public init(json: JSONDictionary) throws {
        name = try json.decode(key: "name")
        age = try json.decode(key: "age")
        date = try json.decode(key: "date")
    }
    
}
