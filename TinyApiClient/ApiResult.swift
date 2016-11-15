//
//  ApiResult.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/15/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

public struct Resource<T> {

    let item: T
    let pagination: PaginationInfo?
    let headers: JSONDictionary?
    
}

public enum ApiResult<T> {

    case success(resource: Resource<T>)

    case clientError(Int)
    case serverError(Int)
    case error(Error)
    case unknownError

    case cancelled

    case notFound
    case unexpectedResponse(Any)

    case invalidToken
    case invalidCredentials
    
}
