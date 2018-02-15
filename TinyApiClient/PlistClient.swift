//
//  PlistClient.swift
//  Pods
//
//  Created by Daniel Lozano Valdés on 4/3/17.
//
//

import Foundation

public enum PlistError: Error {

    case unknownError
    case parseError
    case writeError
    case fileDoesNotExist

}

typealias PropertyList = [String : Any]

public class PlistClient {

    public init() {
        
    }

    public func getResources<T: JSONDeserializable>(file: String) -> [T]? {
        guard let url = try? urlForFileInDocuments(file: file, type: "plist") else {
            return nil
        }

        guard let plist: [PropertyList] = try? plistForFileAt(url: url) else {
            return nil
        }

        return plist.flatMap { try? T(json: $0) }
    }

    public func saveResources<T: JSONSerializable>(file: String, resources: [T]) throws {
        let url = try urlForFileInDocuments(file: file, type: "plist")
        let plist: [PropertyList] = resources.map{ $0.json }
        try savePlist(plist: plist, toUrl: url)
    }

    public func deleteResources(file: String) throws {
        let url = try urlForFileInDocuments(file: file, type: "plist")
        try deleteFileAt(url: url)
    }

    // MARK: - Plist

    func savePlist(plist: PropertyList, toUrl url: URL) throws {
        let success = (plist as NSDictionary).write(to: url, atomically: true)
        if !success {
            throw PlistError.writeError
        }
    }

    func savePlist(plist: [PropertyList], toUrl url: URL) throws {
        let success = (plist as NSArray).write(to: url, atomically: true)
        if !success {
            throw PlistError.writeError
        }
    }

    func plistForFileAt(url: URL) throws -> PropertyList {
        let data = try Data(contentsOf: url)
        guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? PropertyList else {
            throw PlistError.parseError
        }
        return plist
    }

    func plistForFileAt(url: URL) throws -> [PropertyList] {
        let data = try Data(contentsOf: url)
        guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [PropertyList] else {
            throw PlistError.parseError
        }
        return plist
    }

    // MARK: - File Helper's

    func deleteFileAt(url: URL) throws {
        let fileManager = FileManager.default
        try fileManager.removeItem(at: url)
    }

    func urlForFileInDocuments(file: String, type: String) throws -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)

        guard let documentsDir = urls.first else {
            throw PlistError.unknownError
        }

        let plist = documentsDir.appendingPathComponent("\(file).\(type)")
        return plist
//        if try plist.checkResourceIsReachable() {
//            return plist
//        } else {
//            throw PlistError.fileDoesNotExist
//        }
    }

    func urlForFileInBundle(file: String, type: String) throws -> URL {
        guard let url = Bundle.main.url(forResource: file, withExtension: type) else {
            throw PlistError.fileDoesNotExist
        }
        
        return url
    }
    
}
