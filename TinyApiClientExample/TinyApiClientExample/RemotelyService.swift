//
//  RemotelyService.swift
//  TinyApiClientExample
//
//  Created by Daniel Lozano Valdés on 11/29/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import Foundation
import TinyApiClient

public protocol RemotelyService {

    func me(completion: @escaping (RemotelyResult<User>) -> Void)
    func user(userId: String, completion: @escaping (RemotelyResult<User>) -> Void)
    func users(completion: @escaping (RemotelyResult<[User]>) -> Void)
    func userEvents(completion: @escaping (RemotelyResult<[Event]>) -> Void)

}

public enum RemotelyResult<T> {

    case success(resource: T, metadata: RemotelyMetadata)
    case error(message: String)

}

public struct RemotelyMetadata {

    let pagination: PaginationInfo?

}

public class RemotelyAPIService: RemotelyService {

    let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

}

public extension RemotelyAPIService {

    func me(completion: @escaping (RemotelyResult<User>) -> Void) {
        let endpoint = Endpoints.me
        apiClient.GET(endpoint.fullPath) { (result: ApiResult<User>) in
            completion(self.remotelyResultFor(apiResult: result))
        }
    }

    func user(userId: String, completion: @escaping (RemotelyResult<User>) -> Void) {
        let endpoint = Endpoints.user(userId: userId)
        apiClient.GET(endpoint.fullPath) { (result: ApiResult<User>) in
            completion(self.remotelyResultFor(apiResult: result))
        }
    }

    func users(completion: @escaping (RemotelyResult<[User]>) -> Void) {
        let usersEndpoint = Endpoints.users
        apiClient.GET(usersEndpoint.fullPath, rootKey: usersEndpoint.rootKey!) { (apiResult: ApiResult<[User]>) in
            completion(self.remotelyResultFor(apiResult: apiResult))
        }
    }

    func userEvents(completion: @escaping (RemotelyResult<[Event]>) -> Void) {
        let endpoint = Endpoints.userEvents
        apiClient.GET(endpoint.fullPath, rootKey: endpoint.rootKey!) { (result: ApiResult<[Event]>) in
            completion(self.remotelyResultFor(apiResult: result))
        }
    }

}

private extension RemotelyAPIService {

    func remotelyResultFor<T>(apiResult: ApiResult<T>) -> RemotelyResult<T> {
        switch apiResult {
        case .success(let resource, let meta):
            let pagination = meta.pagination
            let metadata = RemotelyMetadata(pagination: pagination)
            return .success(resource: resource, metadata: metadata)
        case .cancelled:
            return .error(message: "cancelled")
        case .clientError(let errorCode):
            return .error(message: "client error = \(errorCode)")
        case .serverError(let errorCode):
            return .error(message: "server error = \(errorCode)")
        case .error(let error):
            return .error(message: "error = \(error)")
        case .invalidCredentials:
            return .error(message: "invalid credentials")
        case .invalidToken:
            return .error(message: "invalid token")
        case .notFound:
            return .error(message: "not found")
        case .unexpectedResponse(let response):
            return .error(message: "unexpected response \(response)")
        case .unknownError:
            return .error(message: "unkown error")
        }
    }

}
