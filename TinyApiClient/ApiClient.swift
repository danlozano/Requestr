//
//  ApiClient.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/15/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

enum HTTPMethod: String {

    case GET
    case POST
    case PUT
    case PATCH
    case DELETE

}

public typealias URLParameters = [String : String]

public typealias HTTPHeader = [AnyHashable : Any]

public class ApiClient {

    lazy var urlSession: URLSession = {
        return URLSession(configuration: self.configuration)
    }()

    lazy var configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = self.defaultHeaders
        return config
    }()

    private var defaultHeaders: HTTPHeader {
        return ["Content-Type" : "application/json; charset=utf-8"]
    }
    
    public var loggingEnabled = false

    public var developmentModeEnabled = false

    fileprivate var currentTasks: Set<URLSessionDataTask> = []

    public init(configuration: URLSessionConfiguration?) {
        if let config = configuration {
            self.configuration = config
        }
    }

    public func setAuthorization(header: String?) {
        if let header = header {
            addToHeader(value: header, key: "Authorization")
        } else {
            addToHeader(value: nil, key: "Authorization")
        }
    }

    public func setAccessToken(token: String?) {
        if let token = token {
            addToHeader(value: "Bearer \(token)", key: "Authorization")
        } else {
            addToHeader(value: nil, key: "Authorization")
        }
    }

    public func addToHeader(value: Any?, key: AnyHashable) {
        var headers: [AnyHashable : Any]

        if let currentHeaders = self.configuration.httpAdditionalHeaders {
            headers = currentHeaders
        } else {
            headers = defaultHeaders
        }

        headers[key] = value

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        urlSession = URLSession(configuration: configuration)
    }

    public func cancelAllRequests() {
        for task in currentTasks {
            task.cancel()
        }
        currentTasks = []
    }

}

// MARK: - REST API

public extension ApiClient {

    // MARK: GET

    // GET Item
    func GET<T: JSONDeserializable>(_ address: String, rootKey: String? = nil, params: URLParameters? = nil, completion: @escaping (ApiResult<T>) -> Void) {
        performRequest(address: address,
                       httpMethod: .GET,
                       rootKey: rootKey,
                       params: params,
                       body: nil,
                       completion: completion)
    }

    // GET Array
    func GET<T: JSONDeserializable>(_ address: String, rootKey: String, params: URLParameters? = nil, completion: @escaping (ApiResult<[T]>) -> Void) {
        performRequest(address: address,
                       httpMethod: .GET,
                       rootKey: rootKey,
                       params: params,
                       body: nil,
                       completion: completion)
    }

    // MARK: POST

    // POST with empty response
    func POST(_ address: String, rootKey: String? = nil, params: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<EmptyResult>) -> Void) {
        performRequest(address: address,
                       httpMethod: .POST,
                       rootKey: rootKey,
                       params: params,
                       body: body,
                       completion: completion)
    }

    // POST with resource as response
    func POST<T: JSONDeserializable>(_ address: String, rootKey: String? = nil, params: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<T>) -> Void) {
        performRequest(address: address,
                       httpMethod: .POST,
                       rootKey: rootKey,
                       params: params,
                       body: body,
                       completion: completion)
    }

    // MARK: PUT

    // PUT with empty response
    func PUT(_ address: String, rootKey: String? = nil, params: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<EmptyResult>) -> Void) {
        performRequest(address: address,
                       httpMethod: .PUT,
                       rootKey: rootKey,
                       params: params,
                       body: body,
                       completion: completion)
    }

    // PUT with resource as response
    func PUT<T: JSONDeserializable>(_ address: String, rootKey: String? = nil, params: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<T>) -> Void) {
        performRequest(address: address,
                       httpMethod: .PUT,
                       rootKey: rootKey,
                       params: params,
                       body: body,
                       completion: completion)
    }

    // MARK: PATCH

    func PATCH<T: JSONDeserializable>(_ address: String, rootKey: String? = nil, params: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<T>) -> Void) {
        performRequest(address: address,
                       httpMethod: .PATCH,
                       rootKey: rootKey,
                       params: params,
                       body: body,
                       completion: completion)
    }

    // MARK: DELETE

    func DELETE<T: JSONDeserializable>(_ address: String, rootKey: String? = nil, params: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<T>) -> Void) {
        performRequest(address: address,
                       httpMethod: .DELETE,
                       rootKey: rootKey,
                       params: params,
                       body: body,
                       completion: completion)
    }

}

// MARK: - Request / URL Helper's

private extension ApiClient {

    func performRequest(address: String, httpMethod: HTTPMethod, rootKey: String?, params: URLParameters?, body: JSONSerializable?, completion: @escaping (ApiResult<EmptyResult>) -> Void) {
        guard let request = makeRequest(address: address, params: params, httpMethod: httpMethod, body: body) else {
            return
        }
        emptyFetch(request: request, completion: completion)
    }

    func performRequest<T: JSONDeserializable>(address: String, httpMethod: HTTPMethod, rootKey: String?, params: URLParameters?, body: JSONSerializable?, completion: @escaping (ApiResult<T>) -> Void) {
        guard let request = makeRequest(address: address, params: params, httpMethod: httpMethod, body: body) else {
            return
        }
        fetchResource(request: request, rootKey: rootKey, completion: completion)
    }

    func performRequest<T: JSONDeserializable>(address: String, httpMethod: HTTPMethod, rootKey: String, params: URLParameters?, body: JSONSerializable?, completion: @escaping (ApiResult<[T]>) -> Void) {
        guard let request = makeRequest(address: address, params: params, httpMethod: httpMethod, body: body) else {
            return
        }
        fetchCollection(request: request, rootKey: rootKey, completion: completion)
    }

    func makeRequest(address: String, params: URLParameters?, httpMethod: HTTPMethod, body: JSONSerializable?) -> URLRequest? {
        do {
            guard let url = makeURL(address: address, params: params) else {
                return nil
            }

            guard httpMethod != .GET else {
                return URLRequest(url: url)
            }

            var request = URLRequest(url: url)
            request.httpMethod = httpMethod.rawValue
            if let body = body {
                let json = body.json
                let bodyData = try JSONSerialization.data(withJSONObject: json, options: [])
                request.httpBody = bodyData
            }

            return request
        } catch {
            print("ERROR CONVERTING BODY TO JSON")
            return nil
        }
    }

    func makeURL(address: String, params: URLParameters?) -> URL? {
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
        fetch(request: request, parseBlock: { (json) -> (resource: EmptyResult?, pagination: PaginationInfo?, other: JSONDictionary?) in
            return (resource: EmptyResult(), pagination: nil, other: nil)
        }, completion: completion)
    }

    func fetchResource<T: JSONDeserializable>(request: URLRequest, rootKey: String?, completion: @escaping (ApiResult<T>) -> Void) {
        fetch(request: request, parseBlock: { (json) -> (resource: T?, pagination: PaginationInfo?, other: JSONDictionary?) in
            var resource: T?
            var finalJSON: JSONDictionary?

            if let rootJSON = json as? JSONDictionary {
                if let rootKey = rootKey, let extractedJSON = rootJSON[rootKey] as? JSONDictionary {
                    finalJSON = extractedJSON
                } else {
                    finalJSON = rootJSON
                }
            }

            if self.developmentModeEnabled {
                do {
                    if let finalJSON = finalJSON {
                        resource = try T(json: finalJSON)
                    }
                } catch {
                    fatalError("API CLIENT, DEVELOPMENT MODE: ERROR = \(error)")
                }
            } else {
                if let finalJSON = finalJSON {
                    resource = try? T(json: finalJSON)
                }
            }

            return (resource: resource, pagination: nil, other: nil)
        }, completion: completion)

    }

    func fetchCollection<T: JSONDeserializable>(request: URLRequest, rootKey: String, completion: @escaping (ApiResult<[T]>) -> Void) {
        fetch(request: request, parseBlock: { (json) -> (resource: [T]?, pagination: PaginationInfo?, other: JSONDictionary?) in
            if var rootJSON = json as? JSONDictionary {
                var resources: [T]?

                if self.developmentModeEnabled {
                    do {
                        let values: [JSONDictionary] = try rootJSON.decode(rootKey)
                        resources = try values.flatMap { try T(json: $0) }
                    } catch {
                        fatalError("API CLIENT, DEVELOPMENT MODE: ERROR = \(error)")
                    }
                } else {
                    if let values: [JSONDictionary] = try? rootJSON.decode(rootKey) {
                        resources = values.flatMap { try? T(json: $0) }
                    }
                }

                var other: JSONDictionary? = nil
                rootJSON[rootKey] = nil
                if rootJSON.keys.count > 0 {
                    other = rootJSON
                }

                return (resource: resources, pagination: nil, other: other)
            } else {
                return (resource: nil, pagination: nil, other: nil)
            }
        }, completion: completion)
    }

}

// MARK: - Request

private typealias JsonTaskCompletionHandler = (Any?, HTTPURLResponse?, Error?) -> Void

private extension ApiClient {

    // MARK: NSURLSession - Data Task Creation

    func jsonTaskWithRequest(request: URLRequest, completion: @escaping JsonTaskCompletionHandler) -> URLSessionDataTask {
        var task: URLSessionDataTask!
        task = urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
            self.currentTasks.remove(task)
            let http = response as? HTTPURLResponse
            if let error = error {
                self.debugLog(msg: "Received an error from HTTP \(request.httpMethod ?? "") to \(request.url?.absoluteString ?? "URL")")
                self.debugLog(msg: "Error: \(error)")
                completion(nil, http, error)
            } else {
                self.debugLog(msg: "Received HTTP \(http?.statusCode ?? 0) from \(request.httpMethod ?? "") to \(request.url?.absoluteString ?? "URL")")
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
        currentTasks.insert(task)
        return task
    }

    // MARK: - Fetching

    func fetch<T>(request: URLRequest, parseBlock: @escaping (Any) -> (resource: T?, pagination: PaginationInfo?, other: JSONDictionary?), completion: @escaping (ApiResult<T>) -> Void) {
        ActivityManager.incrementActivityCount()

        let task = jsonTaskWithRequest(request: request as URLRequest) { (json, response, error) in
            DispatchQueue.main.async {
                ActivityManager.decreaseActivityCount()

                if let error = error {
                    self.handleLocalError(error: error, completion: completion)
                } else {
                    if let response = response, let json = json {
                        self.handleResponse(response: response, json: json, parseBlock: parseBlock, completion: completion)
                    } else {
                        completion(.error(.unknownError))
                    }
                }

            }
        }
        task.resume()
    }

    // MARK: - Response Handling

    func handleResponse<T>(response: HTTPURLResponse, json: Any, parseBlock: (Any) -> (resource: T?, pagination: PaginationInfo?, other: JSONDictionary?), completion: (ApiResult<T>) -> Void) {

        switch response.statusCode {
        case 200..<300:
            let parseResult = parseBlock(json)
            if let resource = parseResult.resource {
                let headers = response.allHeaderFields as? Dictionary<String, Any>
                let metadata = Metadata(pagination: parseResult.pagination, headers: headers, other: parseResult.other)
                completion(.success(resource: resource, meta: metadata))
            } else {
                print("API CLIENT: WARNING: Couldn't parse the following JSON as a \(T.self)")
                print(json)
                completion(.error(.unexpectedResponse(json)))
            }
        default:
            handleAPIError(response: response, json: json, completion: completion)
        }

    }

    func handleAPIError<T>(response: HTTPURLResponse, json: Any, completion: (ApiResult<T>) -> Void) {
        let errorMetadata: ErrorMetadata
        let jsonDict = json as? JSONDictionary

        if let errorMessage = jsonDict?["error"] as? String {
            errorMetadata = ErrorMetadata(statusCode: response.statusCode, errorMessages: [errorMessage])
        } else if let errorMessages = jsonDict?["errors"] as? [String] {
            errorMetadata = ErrorMetadata(statusCode: response.statusCode, errorMessages: errorMessages)
        } else {
            errorMetadata = ErrorMetadata(statusCode: response.statusCode, errorMessages: nil)
        }

        switch response.statusCode {
        case 401:
            completion(.error(.invalidToken(errorMetadata)))
        case 402:
            completion(.error(.invalidCredentials(errorMetadata)))
        case 403:
            completion(.error(.invalidToken(errorMetadata)))
        case 404:
            completion(.error(.notFound(errorMetadata)))
        case 400...499:
            completion(.error(.clientError(errorMetadata)))
        case 500...599:
            completion(.error(.serverError(errorMetadata)))
        default:
            print("Received HTTP \(response.statusCode), which was not handled")
        }
    }

    func handleLocalError<T>(error: Error, completion: (ApiResult<T>) -> Void) {
        if (error as NSError).code == -999 {
            completion(.error(.cancelled))
        } else {
            completion(.error(.localError(error)))
        }
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
