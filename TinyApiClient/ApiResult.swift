//
//  ApiResult.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/15/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

public enum ApiResult<T> {

	case success(resource: T, meta: ResponseMetadata)
	case error(ApiError)

}

public struct ResponseMetadata {

	public let statusCode: Int
	public let headers: JSONDictionary?
	public let other: JSONDictionary?

}

public struct ErrorMetadata {

	public let statusCode: Int
	public let errorMessages: [String]?
	public let userInfo: [String : Any]?

}

public enum ApiError: CustomNSError {

    case clientError(ErrorMetadata)
    case serverError(ErrorMetadata)
    case notFound(ErrorMetadata)
	case unauthorized(ErrorMetadata)

	case emptyResponse
	case jsonParseError(Data)
	case resourceParseError(resourceType: Any.Type, json: Any)

	case cancelled
    case localError(Error)
    case unknownError

	// MARK: - Helper's

	public var metadata: ErrorMetadata? {
		switch self {
		case let .clientError(metadata):
			return metadata
		case let .serverError(metadata):
			return metadata
		case let .notFound(metadata):
			return metadata
		case let .unauthorized(metadata):
			return metadata
		default:
			return nil
		}
	}

	// MARK: - CustomNSError

	public static var errorDomain: String {
		return "com.requestr.ApiError"
	}

	public var errorCode: Int {
		switch self {
		case let .clientError(metadata):
			return metadata.statusCode
		case let .serverError(metadata):
			return metadata.statusCode
		case let .notFound(metadata):
			return metadata.statusCode
		case let .unauthorized(metadata):
			return metadata.statusCode
			//
		case .emptyResponse:
			return 1011
		case .jsonParseError:
			return 1010
		case .resourceParseError:
			return 1012
			//
		case .unknownError:
			return 1002
		case .cancelled:
			return 1003
		case let .localError(error):
			return (error as NSError).code
		}
	}

	public var errorUserInfo: [String : Any] {
		switch self {
		case let .clientError(metadata):
			return metadata.userInfo ?? ["error" : "client error"]
		case let .serverError(metadata):
			return metadata.userInfo ?? ["error" : "server error"]
		case let .notFound(metadata):
			return metadata.userInfo ?? ["error" : "not found"]
		case let .unauthorized(metadata):
			return metadata.userInfo ?? ["error" : "unauthorized"]
			//
		case .emptyResponse:
			return ["error" : "empty response"]
		case .jsonParseError:
			return ["error" : "json parse error"]
		case .resourceParseError(let resourceType, let json):
			return ["error" : "resource parse error", "resource type" : "\(resourceType)", "json" : json]
			//
		case .unknownError:
			return ["error" : "unknown"]
		case .cancelled:
			return ["error" : "cancelled"]
		case let .localError(error):
			return ["error" : "local error", "description" : error.localizedDescription]
		}
	}

}

extension ApiError: Equatable {

	public static func == (lhs: ApiError, rhs: ApiError) -> Bool {
		switch (lhs, rhs) {
		case (.clientError, .clientError):
			return true
		case (.serverError, .serverError):
			return true
		case (.notFound, .notFound):
			return true
		case (.unauthorized, .unauthorized):
			return true
			//
		case (.emptyResponse, .emptyResponse):
			return true
		case (.jsonParseError, .jsonParseError):
			return true
		case (.resourceParseError, .resourceParseError):
			return true
			//
		case (.unknownError, .unknownError):
			return true
		case (.cancelled, .cancelled):
			return true
		case (.localError, .localError):
			return true
		default:
			return false
		}
	}
}
