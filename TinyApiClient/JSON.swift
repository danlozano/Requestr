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

public enum JSONDeserializationError: Error, CustomStringConvertible {

    case missingAttribute(key: String, ofType: Any.Type, onDictionary: Dictionary<String,Any>)
    case invalidAttributeType(key: String, expectedType: Any.Type, receivedValue: Any)
    case invalidAttribute(key: String)

	public var description: String {
		switch self {
		case let .missingAttribute(key, ofType, onDictionary):
			return "Missing Attribute: Key = \(key); Type = \(ofType); Dictionary = \(onDictionary)"
		case let .invalidAttributeType(key, expectedType, receivedValue):
			return "Invalid Attribute Type: Key = \(key); Expected Type = \(expectedType); Received Value = \(receivedValue)"
		case let .invalidAttribute(key):
			return "Invalid Attribute: Key = \(key)"
		}
	}

}

// MARK: - Main decode methods

extension Dictionary where Key == String, Value == Any {

    public func decode<T: JSONValue>(_ key: Key) throws -> T {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description, ofType: T.self, onDictionary: self)
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

    public func decodeArray<T: JSONDeserializable>(_ key: Key, throwOnItemFail: Bool = true) throws -> [T] {
        let values: [JSONDictionary] = try decode(key)
        if throwOnItemFail {
            return try values.map { try decode($0) }
        } else {
            return values.flatMap { try? decode($0) }
        }
    }

    public func decode<T: JSONDeserializable>(_ dictionary: JSONDictionary) throws -> T {
        return try T.init(json: dictionary)
    }

}

// MARK: - Helper decode methods

extension Dictionary where Key == String, Value == Any {

    // MARK: Number/String Handling

    public func decodeInt(_ key: Key) throws -> Int {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description, ofType: Int.self, onDictionary: self)
        }

        if let int = value as? Int {
            return int
        } else if let string = value as? String, let int = Int(string) {
            return int
        }

        throw JSONDeserializationError.invalidAttributeType(key: key.description, expectedType: Int.self, receivedValue: value)
    }

    public func decodeDouble(_ key: Key) throws -> Double {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description, ofType: Double.self, onDictionary: self)
        }

        if let double = value as? Double {
            return double
        } else if let string = value as? String, let double = Double(string) {
            return double
        }

        throw JSONDeserializationError.invalidAttributeType(key: key.description, expectedType: Double.self, receivedValue: value)
    }

    // MARK: Enum (String RawValue)

    public func decode<T: RawRepresentable>(_ key: Key) throws -> T where T.RawValue == String {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description, ofType: T.self, onDictionary: self)
        }

        guard let attribute = value as? String else {
            throw JSONDeserializationError.invalidAttributeType(key: key.description, expectedType: T.self, receivedValue: value)
        }

        guard let result = T(rawValue: attribute) else {
            throw JSONDeserializationError.invalidAttribute(key: key.description)
        }

        return result
    }

    public func decode<T: RawRepresentable>(_ key: Key) throws -> T where T.RawValue == Int {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description, ofType: T.self, onDictionary: self)
        }

        guard let attribute = value as? Int else {
            throw JSONDeserializationError.invalidAttributeType(key: key.description, expectedType: T.self, receivedValue: value)
        }

        guard let result = T(rawValue: attribute) else {
            throw JSONDeserializationError.invalidAttribute(key: key.description)
        }

        return result
    }

    // MARK: URL

    public func decode(_ key: Key) throws -> URL {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description, ofType: URL.self, onDictionary: self)
        }

        guard let attribute = value as? String else {
            throw JSONDeserializationError.invalidAttributeType(key: key.description, expectedType: String.self, receivedValue: value)
        }

        guard let result = URL(string: attribute) else {
            throw JSONDeserializationError.invalidAttribute(key: key.description)
        }

        return result
    }

    // MARK: Coordinate

    public func decode(latitudeKey: Key, longitudeKey: Key) throws -> CLLocationCoordinate2D {
        guard let latitudeValue = self[latitudeKey] else {
            throw JSONDeserializationError.missingAttribute(key: latitudeKey.description, ofType: CLLocationCoordinate2D.self, onDictionary: self)
        }

        guard let longitudeValue = self[longitudeKey] else {
            throw JSONDeserializationError.missingAttribute(key: longitudeKey.description, ofType: CLLocationCoordinate2D.self, onDictionary: self)
        }

        guard let latitude = latitudeValue as? Double else {
            throw JSONDeserializationError.invalidAttributeType(key: latitudeKey.description, expectedType: Double.self, receivedValue: latitudeValue)
        }

        guard let longitude = longitudeValue as? Double else {
            throw JSONDeserializationError.invalidAttributeType(key: longitudeKey.description, expectedType: Double.self, receivedValue: longitudeValue)
        }

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public func decodeStringKeys(latitudeKey: Key, longitudeKey: Key) throws -> CLLocationCoordinate2D {
        guard let latitudeValue = self[latitudeKey] else {
            throw JSONDeserializationError.missingAttribute(key: latitudeKey.description, ofType: CLLocationCoordinate2D.self, onDictionary: self)
        }

        guard let longitudeValue = self[longitudeKey] else {
            throw JSONDeserializationError.missingAttribute(key: longitudeKey.description, ofType: CLLocationCoordinate2D.self, onDictionary: self)
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

    public func decode(_ key: Key, withFormatter dateFormatter: DateFormatter, alternate: DateFormatter? = nil) throws -> Date {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description, ofType: Date.self, onDictionary: self)
        }

        guard let dateString = value as? String else {
            throw JSONDeserializationError.invalidAttributeType(key: key.description, expectedType: String.self, receivedValue: value)
        }

        if let date = dateFormatter.date(from: dateString) {
            return date
        }

        if let alternateDateFormatter = alternate, let alternateDate = alternateDateFormatter.date(from: dateString) {
            return alternateDate
        } else {
            throw JSONDeserializationError.invalidAttribute(key: key.description)
        }
    }

    public func decode(_ key: Key) throws -> Date {
        guard let value = self[key] else {
            throw JSONDeserializationError.missingAttribute(key: key.description, ofType: Date.self, onDictionary: self)
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
