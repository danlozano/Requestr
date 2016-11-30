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
    func login(loginRequest: LoginRequest, completion: @escaping (RemotelyResult<User>) -> Void)
    func users(completion: @escaping (RemotelyResult<[User]>) -> Void)
}

public enum RemotelyResult<T> {
    case success(resource: T, metadata: Metadata)
    case error(message: String)
}

public struct Metadata {
    let pagination: PaginationInfo?
    let accessToken: String?
}

public class RemotelyAPIService: RemotelyService {

    let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

}

public extension RemotelyAPIService {

    func login(loginRequest: LoginRequest, completion: @escaping (RemotelyResult<User>) -> Void) {
        apiClient.POST(Endpoints.login.fullPath, body: loginRequest) { (apiResult: ApiResult<User>) in
            completion(self.remotelyResultFor(apiResult: apiResult))
        }
    }

    func users(completion: @escaping (RemotelyResult<[User]>) -> Void) {
        let usersEndpoint = Endpoints.users
        apiClient.GET(usersEndpoint.fullPath, rootKey: usersEndpoint.rootKey!) { (apiResult: ApiResult<[User]>) in
            completion(self.remotelyResultFor(apiResult: apiResult))
        }
    }

}

private extension RemotelyAPIService {

    func remotelyResultFor<T>(apiResult: ApiResult<T>) -> RemotelyResult<T> {
        switch apiResult {
        case .success(let resource, let meta):
            let pagination = meta.pagination
            let accessToken = meta.headers?["Accesstoken"] as? String
            let metadata = Metadata(pagination: pagination, accessToken: accessToken)
            return .success(resource: resource, metadata: metadata)
        case .cancelled:
            return .error(message: "")
        case .clientError(let errorCode):
            return .error(message: "\(errorCode)")
        case .serverError(let errorCode):
            return .error(message: "\(errorCode)")
        case .error(let error):
            return .error(message: "\(error)")
        case .invalidCredentials:
            return .error(message: "")
        case .invalidToken:
            return .error(message: "")
        case .notFound:
            return .error(message: "")
        case .unexpectedResponse(let response):
            return .error(message: "\(response)")
        case .unknownError:
            return .error(message: "")
        }
    }

    func test() {

        let user = User(id: "", email: "", name: "")

        apiClient.DELETE("/user/123", rootKey: "user", body: nil) { (result: ApiResult<User>) in

        }

        apiClient.POST("/user", rootKey: "user", body: user) { (result: ApiResult<EmptyResult>) in
            switch result {
            case .success(let resource, let meta):
                let user = resource
                let pagination = meta.pagination
                let headers = meta.headers
                print("SUCCESS: \(user) : \(pagination) : \(headers)")
            default:
                break
            }
        }

        apiClient.GET("/users", rootKey: "users") { (result: ApiResult<[User]>) in
            switch result {
            case .success(let resource, let meta):
                let users = resource
                let pagination = meta.pagination
                let headers = meta.headers
                print("SUCCESS: \(users) : \(pagination) : \(headers)")
            default:
                break
            }
        }

        apiClient.GET("/user", params: ["thing" : "thing"]) { (result: ApiResult<User>) in
            switch result {
            case .success(let resource, let meta):
                let user = resource
                let pagination = meta.pagination
                let headers = meta.headers
                print("SUCCESS: \(user) : \(pagination) : \(headers)")
            default:
                break
            }
        }

        apiClient.GET("/post", rootKey: "user") { (result: ApiResult<User>) in
            switch result {
            case .success(let resource, let meta):
                let user = resource
                let pagination = meta.pagination
                let headers = meta.headers
                print("SUCCESS: \(user) : \(pagination) : \(headers)")
            default:
                break
            }
        }

        apiClient.GET("/user") { (result: ApiResult<User>) in
            switch result {
            case .success(let resource, let meta):
                let user = resource
                let pagination = meta.pagination
                let headers = meta.headers
                print("SUCCESS: \(user) : \(pagination) : \(headers)")
            default:
                break
            }
        }
        
    }

}
