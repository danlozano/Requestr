//
//  JSON.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/9/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

// Inspired from Sam Soffes simple JSON micro-framework https://github.com/soffes/JSON

import Foundation

public typealias JSONDictionary = [String: Any]

public protocol JSONDeserializable {
    init(json: JSONDictionary) throws
}

public protocol JSONSerializable {
    var json: JSONDictionary { get }
}

public struct JSON {

    public enum DeserializationError: Error {
        case missingAttribute(key: String)
        case invalidAttributeType(key: String, expectedType: Any.Type, receivedValue: Any)
        case invalidAttribute(key: String)
    }

    static func decode<T>(_ dictionary: JSONDictionary, key: String) throws -> T {
        guard let value = dictionary[key] else {
            throw JSON.DeserializationError.missingAttribute(key: key)
        }

        guard let attribute = value as? T else {
            throw JSON.DeserializationError.invalidAttributeType(key: key, expectedType: T.self, receivedValue: value)
        }

        return attribute
    }

    static func decode<T: JSONDeserializable>(_ dictionary: JSONDictionary, key: String) throws -> T {
        let value: JSONDictionary = try decode(dictionary, key: key)
        return try decode(value)
    }

    static func decode<T: JSONDeserializable>(_ dictionary: JSONDictionary, key: String) throws -> [T] {
        let values: [JSONDictionary] = try decode(dictionary, key: key)
        return values.flatMap { try? decode($0) }
    }

    static func decode<T: JSONDeserializable>(_ dictionary: JSONDictionary) throws -> T {
        return try T.init(json: dictionary)
    }

}
