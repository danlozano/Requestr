//
//  Event.swift
//  TinyApiClientExample
//
//  Created by Daniel Lozano Valdés on 12/8/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import Foundation
import TinyAPIClient

public struct Event {

    let id: String
    let userId: String
    let date: String

}

extension Event: JSONDeserializable {

    public init(json: JSONDictionary) throws {
        id = try json.decode("id")
        userId = try json.decode("userId")
        date = try json.decode("date")
    }
    
}
