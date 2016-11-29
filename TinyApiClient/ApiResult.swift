//
//  ApiResult.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/15/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

public struct Metadata {
    public let pagination: PaginationInfo?
    public let headers: JSONDictionary?
}

public enum ApiResult<T> {
    case success(resource: T, meta: Metadata)
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
