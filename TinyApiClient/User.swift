//
//  User.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/9/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

struct User: JSONSerializable {

    var json: JSONDictionary {
        return [
            "name" : name,
            "age" : age,
            "date" : date
        ]
    }

    let name: String
    let age: Int
    let date: Date

}

extension User: JSONDeserializable {

    init(json: JSONDictionary) throws {
        name = try JSON.decode(json, key: "name")
        age = try JSON.decode(json, key: "age")
        date = try JSON.decode(json, key: "date")
    }
    
}

extension JSON {

    static func decode(_ dictionary: JSONDictionary, key: String) throws -> Date {
        guard let value = dictionary[key] else {
            throw JSON.DeserializationError.missingAttribute(key: key)
        }

        if #available(iOSApplicationExtension 10.0, OSXApplicationExtension 10.12, watchOSApplicationExtension 3.0, tvOSApplicationExtension 10.0, *) {
            if let string = value as? String {
                guard let date = ISO8601DateFormatter().date(from: string) else {
                    throw JSON.DeserializationError.invalidAttribute(key: key)
                }

                return date
            }
        }

        if let timeInterval = value as? TimeInterval {
            return Date(timeIntervalSince1970: timeInterval)
        }

        if let timeInterval = value as? Int {
            return Date(timeIntervalSince1970: TimeInterval(timeInterval))
        }
        
        throw JSON.DeserializationError.invalidAttributeType(key: key, expectedType: String.self, receivedValue: value)
    }

}
