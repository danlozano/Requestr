//
//  User.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/9/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

struct User: JSONSerializable {

    let name: String
    let age: Int
    let date: Date

    var json: JSONDictionary {
        return [
            "name" : name,
            "age" : age,
            "date" : date
        ]
    }

    init(name: String, age: Int, date: Date) {
        self.name = name
        self.age = age
        self.date = date
    }

}

extension User: JSONDeserializable {

    init(json: JSONDictionary) throws {
        name = try json.decode("name")
        age = try json.decode("age")
        date = try json.decode("date")
    }
    
}
