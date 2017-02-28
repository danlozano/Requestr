//
//  JSON.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/9/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

// Inspired from Sam Soffes simple JSON micro-framework https://github.com/soffes/JSON

import Foundation
import CoreLocation

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
extension Double: JSONValue { }

public enum JSONDeserializationError: Error {

    case missingAttribute(key: String)

    case invalidAttributeType(key: String, expectedType: Any.Type, receivedValue: Any)

    case invalidAttribute(key: String)

}

// MARK: - Main decode methods

extension Dictionary where Key: CustomStringConvertible, Value: Any {

    public func decode<T: JSONValue>(_ key: Key) throws -> T {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description)
        }

        guard let attribute = value as? T else {
            throw JSONDeserializationError.invalidAttributeType(key: key.description, expectedType: T.self, receivedValue: value)
        }

        return attribute
    }

    public func decode<T: JSONDeserializable>(_ key: Key) throws -> T {
        let value: JSONDictionary = try decode(key)
        return try decode(value)
    }

    public func decodeArray<T: JSONDeserializable>(_ key: Key) throws -> [T] {
        let values: [JSONDictionary] = try decode(key)
        return values.flatMap { try? decode($0) }
    }

    public func decode<T: JSONDeserializable>(_ dictionary: JSONDictionary) throws -> T {
        return try T.init(json: dictionary)
    }

}

// MARK: - Helper decode methods

extension Dictionary where Key: CustomStringConvertible, Value: Any {

    // MARK: Coordinate

    public func decode(latitudeKey: Key, longitudeKey: Key) throws -> CLLocationCoordinate2D {
        guard let latitudeValue = self[latitudeKey] else {
            throw JSONDeserializationError.missingAttribute(key: latitudeKey.description)
        }

        guard let longitudeValue = self[longitudeKey] else {
            throw JSONDeserializationError.missingAttribute(key: longitudeKey.description)
        }

        guard let latitude = latitudeValue as? String else {
            throw JSONDeserializationError.invalidAttributeType(key: latitudeKey.description, expectedType: String.self, receivedValue: latitudeValue)
        }

        guard let longitude = longitudeValue as? String else {
            throw JSONDeserializationError.invalidAttributeType(key: longitudeKey.description, expectedType: String.self, receivedValue: longitudeValue)
        }

        guard let lat = Double(latitude.trimmingCharacters(in: .whitespaces)) else {
            throw JSONDeserializationError.invalidAttributeType(key: latitudeKey.description, expectedType: Double.self, receivedValue: latitude)
        }

        guard let lng = Double(longitude.trimmingCharacters(in: .whitespaces)) else {
            throw JSONDeserializationError.invalidAttributeType(key: longitudeKey.description, expectedType: Double.self, receivedValue: longitude)
        }

        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    // MARK: Date

    public func decode(_ key: Key) throws -> Date {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description)
        }

        if #available(iOSApplicationExtension 10.0, OSXApplicationExtension 10.12, watchOSApplicationExtension 3.0, tvOSApplicationExtension 10.0, *) {
            if let string = value as? String {
                if #available(iOS 10.0, *) {
                    guard let date = ISO8601DateFormatter().date(from: string) else {
                        throw JSONDeserializationError.invalidAttribute(key: key.description)
                    }
                    return date
                } else {
                    guard let date = DateHelper.ISO8601DateFormatter.date(from: string) else {
                        throw JSONDeserializationError.invalidAttribute(key: key.description)
                    }
                    return date
                }
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

enum DateHelper {

    static let ISO8601DateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter
    }()
    
}
