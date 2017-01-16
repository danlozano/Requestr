//
//  AuthService.swift
//  TinyApiClientExample
//
//  Created by Daniel Lozano Valdés on 11/30/16.
//  Copyright © 2016 danielozano. All rights reserved.
//

import Foundation
import TinyAPIClient

public protocol AuthService {

    func login(loginRequest: LoginRequest, completion: @escaping (AuthResult) -> Void)
    func signup(signupRequest: SignupRequest, completion: @escaping (AuthResult) -> Void)

}

public enum AuthResult {

    case success(user: User, accessToken: String)
    case error(message: String)

}

public class AuthApiService: AuthService {

    let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

}

public extension AuthApiService {

    func login(loginRequest: LoginRequest, completion: @escaping (AuthResult) -> Void) {
        let endpoint = Endpoints.login
        apiClient.POST(endpoint.fullPath, body: loginRequest) { (result: ApiResult<User>) in
            completion(self.authResultFor(apiResult: result))
        }
    }

    func signup(signupRequest: SignupRequest, completion: @escaping (AuthResult) -> Void) {
        let endpoint = Endpoints.signup
        apiClient.POST(endpoint.fullPath, rootKey: endpoint.rootKey, body: signupRequest) { (result: ApiResult<User>) in
            completion(self.authResultFor(apiResult: result))
        }
    }

}

private extension AuthApiService {

    func authResultFor(apiResult: ApiResult<User>) -> AuthResult {
        switch apiResult {
        case .success(let user, let meta):
            if let accessToken = meta.headers?["Accesstoken"] as? String {
                return .success(user: user, accessToken: accessToken)
            } else {
                return .error(message: "missing access token in response")
            }
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

}
