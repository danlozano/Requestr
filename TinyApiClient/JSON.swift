//
//  JSON.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/9/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

// Inspired from Sam Soffes simple JSON micro-framework https://github.com/soffes/JSON

import Foundation

public typealias JSONDictionary = [String : Any]

public protocol JSONDeserializable {
    init(json: JSONDictionary) throws
}

public protocol JSONSerializable {
    var json: JSONDictionary { get }
}

public protocol JSONValue { }
extension Array: JSONValue { }
extension Dictionary: JSONValue { }
extension String: JSONValue { }
extension Bool: JSONValue { }
extension Int: JSONValue { }

extension Dictionary where Key: CustomStringConvertible, Value: Any {

    func decode<T: JSONValue>(key: Key) throws -> T {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description)
        }

        guard let attribute = value as? T else {
            throw JSONDeserializationError.invalidAttributeType(key: key.description, expectedType: T.self, receivedValue: value)
        }

        return attribute
    }

    func decode<T: JSONDeserializable>(key: Key) throws -> T {
        let value: JSONDictionary = try decode(key: key)
        return try decode(value)
    }

    func decode<T: JSONDeserializable>(key: Key) throws -> [T] {
        let values: [JSONDictionary] = try decode(key: key)
        return values.flatMap { try? decode($0) }
    }

    func decode<T: JSONDeserializable>(_ dictionary: JSONDictionary) throws -> T {
        return try T.init(json: dictionary)
    }

}

extension Dictionary where Key: CustomStringConvertible, Value: Any {

    func decode(key: Key) throws -> Date {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description)
        }

        if #available(iOSApplicationExtension 10.0, OSXApplicationExtension 10.12, watchOSApplicationExtension 3.0, tvOSApplicationExtension 10.0, *) {
            if let string = value as? String {
                guard let date = ISO8601DateFormatter().date(from: string) else {
                    throw JSONDeserializationError.invalidAttribute(key: key.description)
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

        throw JSONDeserializationError.invalidAttributeType(key: key.description, expectedType: String.self, receivedValue: value)
    }
    
}

public enum JSONDeserializationError: Error {
    case missingAttribute(key: String)
    case invalidAttributeType(key: String, expectedType: Any.Type, receivedValue: Any)
    case invalidAttribute(key: String)
}

//public enum JSON {
//
//    public enum DeserializationError: Error {
//        case missingAttribute(key: String)
//        case invalidAttributeType(key: String, expectedType: Any.Type, receivedValue: Any)
//        case invalidAttribute(key: String)
//    }
//
//    static func decode<T: JSONValue>(_ dictionary: JSONDictionary, key: String) throws -> T {
//        guard let value = dictionary[key] else {
//            throw JSON.DeserializationError.missingAttribute(key: key)
//        }
//
//        guard let attribute = value as? T else {
//            throw JSON.DeserializationError.invalidAttributeType(key: key, expectedType: T.self, receivedValue: value)
//        }
//
//        return attribute
//    }
//
//    static func decode<T: JSONDeserializable>(_ dictionary: JSONDictionary, key: String) throws -> T {
//        let value: JSONDictionary = try decode(dictionary, key: key)
//        return try decode(value)
//    }
//
//    static func decode<T: JSONDeserializable>(_ dictionary: JSONDictionary, key: String) throws -> [T] {
//        let values: [JSONDictionary] = try decode(dictionary, key: key)
//        return values.flatMap { try? decode($0) }
//    }
//
//    static func decode<T: JSONDeserializable>(_ dictionary: JSONDictionary) throws -> T {
//        return try T.init(json: dictionary)
//    }
//
//}
