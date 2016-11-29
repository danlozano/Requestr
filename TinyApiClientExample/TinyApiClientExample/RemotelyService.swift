//
//  RemotelyService.swift
//  TinyApiClientExample
//
//  Created by Daniel Lozano Valdés on 11/29/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import Foundation
import TinyApiClient

enum Endpoints {

    static let baseURL = "https://remotelyapi.herokuapp.com"

    case login
    case me
    case user(userId: Int)
    case users

    var fullPath: String {
        let path: String
        switch self {
        case .login:
            path = "/login"
        case .me:
            path = "/api/me"
        case .user(let userId):
            path = "/api/users/\(userId)"
        case .users:
            path = "/users"
        }
        return Endpoints.baseURL + path
    }

}

public struct LoginRequest: JSONSerializable {

    let email: String
    let password: String

    public var json: JSONDictionary {
        return ["email" : email,
                "password" : password]
    }

}

public class RemotelyService {

    let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

}

public extension RemotelyService {

    func login(loginRequest: LoginRequest, completion: @escaping (ApiResult<User>) -> Void) {
        apiClient.POST(Endpoints.login.fullPath,
                       body: loginRequest,
                       completion: completion)
    }

}

private extension RemotelyService {

    func test() {

        let user = User(name: "Daniel Lozano", age: 27, date: Date())

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
