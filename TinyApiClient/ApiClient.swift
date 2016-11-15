//
//  ApiClient.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/15/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

public class ApiClient {

    let configuration: URLSessionConfiguration
    lazy var urlSession: URLSession = {
        return URLSession(configuration: self.configuration)
    }()

    var loggingEnabled = false
    fileprivate var currentTasks: Set<URLSessionDataTask> = []

    public init(configuration: URLSessionConfiguration) {
        self.configuration = configuration
    }

    func cancelAllRequests() {
        for task in currentTasks {
            task.cancel()
        }
        currentTasks = []
    }

    // MARK: - Public HTTP Methods

    func test() {

        GET("/post", rootKey: "user") { (result: ApiResult<User>) in
            switch result {
            case .success(let resource):
                let user = resource.item
                let pagination = resource.pagination
                let headers = resource.headers
                print("SUCCESS: \(user) : \(pagination) : \(headers)")
            default:
                break
            }
        }

        GET("/post") { (result: ApiResult<User>) in
            switch result {
            case .success(let resource):
                let user = resource.item
                let pagination = resource.pagination
                let headers = resource.headers
                print("SUCCESS: \(user) : \(pagination) : \(headers)")
            default:
                break
            }
        }

    }

    func GET<T: JSONDeserializable>(_ address: String, rootKey: String? = nil, params: [String: String]? = nil, completion: @escaping (ApiResult<T>) -> Void) {
        guard let request = makeRequest(address: address, params: params) else {
            return
        }
        fetchResource(request: request, rootKey: rootKey, completion: completion)
    }

}

// MARK: - URL Helper's

private extension ApiClient {

    func makeRequest(address: String, params: [String: String]? = nil) -> URLRequest? {
        guard let url = makeURL(address: address, params: params) else {
            return nil
        }
        return URLRequest(url: url)
    }

    func makeURL(address: String, params: [String: String]?) -> URL? {
        guard let params = params else {
            return URL(string: address)
        }

        guard let url = URL(string: address),
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return nil
        }

        let queryItems: [URLQueryItem] = params.map { (key, value) -> URLQueryItem in
            return URLQueryItem(name: key, value: value)
        }

        components.queryItems = queryItems
        return components.url
    }

}

// MARK: - Parsing

private extension ApiClient {

    func emptyFetch(request: URLRequest, completion: @escaping (ApiResult<EmptyResult>) -> Void) {
        fetch(request: request, parseBlock: { (json) -> (resource: EmptyResult?, pagination: PaginationInfo?) in
            return (resource: EmptyResult(), pagination: nil)
        }, completion: completion)
    }

    func fetchResource<T: JSONDeserializable>(request: URLRequest, rootKey: String?, completion: @escaping (ApiResult<T>) -> Void) {
        fetch(request: request, parseBlock: { (json) -> (resource: T?, pagination: PaginationInfo?) in
            var resource: T?
            var finalJSON: JSONDictionary?

            if let rootJSON = json as? JSONDictionary {
                if let rootKey = rootKey, let extractedJSON = rootJSON[rootKey] as? JSONDictionary {
                    finalJSON = extractedJSON
                } else {
                    finalJSON = rootJSON
                }
            }

            if let finalJSON = finalJSON {
                resource = try? JSON.decode(finalJSON)
            }

            return (resource: resource, pagination: nil)
        }, completion: completion)

    }

    func fetchCollection<T: JSONDeserializable>(request: URLRequest, rootKey: String, completion: @escaping (ApiResult<[T]>) -> Void) {
        fetch(request: request, parseBlock: { (json) -> (resource: [T]?, pagination: PaginationInfo?) in
            if let rootJSON = json as? JSONDictionary {
                var resources: [T]?
                if let values: [JSONDictionary] = try? JSON.decode(rootJSON, key: rootKey) {
                    resources = values.flatMap { try? JSON.decode($0) }
                }
                return (resource: resources, pagination: nil)
            }else{
                return (resource: nil, pagination: nil)
            }
        }, completion: completion)
    }

}

// MARK: - Fetching

typealias JsonTaskCompletionHandler = (Any?, HTTPURLResponse?, Error?) -> Void

private extension ApiClient {

    func fetch<T>(request: URLRequest, parseBlock: @escaping (Any) -> (resource: T?, pagination: PaginationInfo?), completion: @escaping (ApiResult<T>) -> Void) {

        ActivityManager.incrementActivityCount()

        let task = jsonTaskWithRequest(request: request as URLRequest) { (json, response, error) in
            DispatchQueue.main.async {
                ActivityManager.decreaseActivityCount()

                if let error = error {
                    self.handleError(error: error, completion: completion)
                } else {
                    if let response = response, let json = json {
                        self.handleResponse(response: response, json: json, parseBlock: parseBlock, completion: completion)
                    } else {
                        completion(.unknownError)
                    }
                }

            }
        }
        task.resume()
    }

    func handleError<T>(error: Error, completion: (ApiResult<T>) -> Void) {
        if (error as NSError).code == -999 {
            completion(.cancelled)
        } else {
            completion(.error(error))
        }
    }

    func handleResponse<T>(response: HTTPURLResponse, json: Any,
                        parseBlock: (Any) -> (resource: T?, pagination: PaginationInfo?),
                        completion: (ApiResult<T>) -> Void) {
        switch response.statusCode {
        case 200:
            let parseResult = parseBlock(json)
            if let resource = parseResult.resource {
                let headers = response.allHeaderFields as? Dictionary<String, Any>
                let resource = Resource(item: resource, pagination: parseResult.pagination, headers: headers)
                completion(.success(resource: resource))
            } else {
                print("API CLIENT: WARNING: Couldn't parse the following JSON as a \(T.self)")
                print(json)
                completion(.unexpectedResponse(json))
            }
        case 402:
            completion(.invalidCredentials)
        case 403:
            completion(.invalidToken)
        case 404:
            completion(.notFound)
        case 400...499:
            completion(.clientError(response.statusCode))
        case 500...599:
            completion(.serverError(response.statusCode))
        default:
            print("Received HTTP \(response.statusCode), which was not handled")
        }
    }

    // MARK: NSURLSession - Data Task

    func jsonTaskWithRequest(request: URLRequest, completion: @escaping JsonTaskCompletionHandler) -> URLSessionDataTask {
        var task: URLSessionDataTask?
        task = urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
            self.currentTasks.remove(task!) // swiftlint:disable:this force_unwrapping
            let http = response as? HTTPURLResponse

            if let error = error {
                self.debugLog(msg: "Received an error from HTTP \(request.httpMethod ?? "") to \(request.url?.absoluteString)")
                self.debugLog(msg: "Error: \(error)")
                completion(nil, http, error)
            } else {
                self.debugLog(msg: "Received HTTP \(http?.statusCode) from \(request.httpMethod ?? "") to \(request.url?.absoluteString)")
                if let data = data {
                    do {
                        self.debugResponseData(data: data)
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                        completion(jsonObject, http, nil)
                    } catch {
                        self.debugLog(msg: "Error parsing response as JSON")
                        completion(nil, http, NSError(domain: "com.icalialabs.jsonerror", code: 10, userInfo: nil))
                    }
                } else {
                    completion(nil, http, NSError(domain: "com.icalialabs.emptyresponse", code: 11, userInfo: nil))
                }
            }

        })
        currentTasks.insert(task!) // swiftlint:disable:this force_unwrapping
        return task! // swiftlint:disable:this force_unwrapping
    }

}

// MARK: - Debug Logging

private extension ApiClient {

    func debugLog(msg: String) {
        guard loggingEnabled else { return }
        print(msg)
    }

    func debugResponseData(data: Data) {
        guard loggingEnabled else { return }
        if let body = String(data: data, encoding: String.Encoding.utf8) {
            print(body)
        } else {
            print("<empty response>")
        }
    }
    
}
