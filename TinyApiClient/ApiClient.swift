//
//  ApiClient.swift
//  TinyApiClient
//
//  Created by Daniel Lozano on 11/15/16.
//  Copyright © 2016 Daniel Lozano. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

public typealias URLParameters = [String : String]
public typealias HTTPHeader = [AnyHashable : Any]

public class ApiClient {

	enum Error: Swift.Error {
		case failedCastToJSONDictionary(Any)
		case failedCastToJSONDictionaryArray(Any)
		case invalidTypeForRootKey(type: Any.Type, rootKey: String)
		case missingRootKey(rootKey: String, onDict: JSONDictionary)
	}

    lazy var urlSession: URLSession = {
        return URLSession(configuration: self.configuration)
    }()

    lazy var configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = self.defaultHeaders
        return config
    }()

	public let defaultHeaders: HTTPHeader = ["Content-Type" : "application/json; charset=utf-8"]

    public var loggingEnabled = false

    public var developmentModeEnabled = false

    fileprivate var currentTasks: Set<URLSessionDataTask> = []

	public init(configuration: URLSessionConfiguration?) {
		if let configuration = configuration {
			self.configuration = configuration
		}
	}

    public func cancelAllRequests() {
		currentTasks.forEach { $0.cancel() }
        currentTasks = []
    }

}

// MARK: - Header's

public extension ApiClient {

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

}

// MARK: - REST API

public extension ApiClient {

	// MARK: - Resource Loading

	func loadResource<R: Resource,T>(_ resource: R, completion: @escaping (ApiResult<T>) -> Void) -> URLSessionDataTask? where T == R.Model {
		guard let urlRequest = resource.request.urlRequest else {
			return nil
		}

		return fetchResource(request: urlRequest, rootKey: resource.rootKey, initialization: resource.parser, errorParser: resource.errorParser, completion: completion)
	}

	// MARK: - RequestProtocol Loading

	func loadRequest(_ request: Request, errorParser: ((Any) -> [String]?)? = nil, completion: @escaping (ApiResult<EmptyResult>) -> Void) -> URLSessionDataTask? {
		guard let urlRequest = request.urlRequest else {
			return nil
		}

		return emptyFetch(request: urlRequest, errorParser: nil, completion: completion)
	}

	func loadRequest<T: JSONDeserializable>(_ request: Request, rootKey: String? = nil, errorParser: ((Any) -> [String]?)? = nil, completion: @escaping (ApiResult<T>) -> Void) -> URLSessionDataTask? {
		guard let urlRequest = request.urlRequest else {
			return nil
		}

		let initializationBlock: (Any) throws -> T = { (jsonAny) in
			guard let jsonDict = jsonAny as? JSONDictionary else {
				throw ApiClient.Error.failedCastToJSONDictionary(jsonAny)
			}
			return try T.init(json: jsonDict)
		}

		return fetchResource(request: urlRequest, rootKey: rootKey, initialization: initializationBlock, errorParser: errorParser, completion: completion)
	}

	func loadRequest<T: JSONDeserializable>(_ request: Request, rootKey: String? = nil, errorParser: ((Any) -> [String]?)? = nil, completion: @escaping (ApiResult<[T]>) -> Void) -> URLSessionDataTask? {
		guard let urlRequest = request.urlRequest else {
			return nil
		}

		let initializationBlock: (Any) throws -> [T] = { (jsonAny) in
			guard let jsonDictArray = jsonAny as? [JSONDictionary] else {
				throw ApiClient.Error.failedCastToJSONDictionaryArray(jsonAny)
			}
			if self.developmentModeEnabled {
				return try jsonDictArray.map { try T(json: $0) }
			} else {
				return jsonDictArray.flatMap { try? T(json: $0) }
			}
		}

		return fetchResource(request: urlRequest, rootKey: rootKey, initialization: initializationBlock, errorParser: errorParser, completion: completion)
	}

    // MARK: GET

    // GET Item
    @discardableResult
    func GET<T: JSONDeserializable>(_ address: Address, rootKey: String? = nil, parameters: URLParameters? = nil, completion: @escaping (ApiResult<T>) -> Void) -> URLSessionDataTask? {
		let request = BasicRequest(method: .GET, address: address, parameters: parameters, body: nil)
		return loadRequest(request, rootKey: rootKey, completion: completion)
    }

    // GET Array
    @discardableResult
    func GET<T: JSONDeserializable>(_ address: Address, rootKey: String? = nil, parameters: URLParameters? = nil, completion: @escaping (ApiResult<[T]>) -> Void) -> URLSessionDataTask? {
		let request = BasicRequest(method: .GET, address: address, parameters: parameters, body: nil)
		return loadRequest(request, rootKey: rootKey, completion: completion)
    }

    // MARK: POST

    // POST with empty response
    @discardableResult
    func POST(_ address: Address, parameters: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<EmptyResult>) -> Void) -> URLSessionDataTask? {
		let request = BasicRequest(method: .POST, address: address, parameters: parameters, body: body)
		return loadRequest(request, completion: completion)
    }

    // POST with resource as response
    @discardableResult
    func POST<T: JSONDeserializable>(_ address: Address, rootKey: String? = nil, parameters: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<T>) -> Void) -> URLSessionDataTask? {
		let request = BasicRequest(method: .POST, address: address, parameters: parameters, body: body)
		return loadRequest(request, rootKey: rootKey, completion: completion)
    }

    // MARK: PUT

    // PUT with empty response
    @discardableResult
    func PUT(_ address: Address, parameters: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<EmptyResult>) -> Void) -> URLSessionDataTask? {
		let request = BasicRequest(method: .PUT, address: address, parameters: parameters, body: body)
		return loadRequest(request, completion: completion)
    }

    // PUT with resource as response
    @discardableResult
    func PUT<T: JSONDeserializable>(_ address: Address, rootKey: String? = nil, parameters: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<T>) -> Void) -> URLSessionDataTask? {
		let request = BasicRequest(method: .PUT, address: address, parameters: parameters, body: body)
		return loadRequest(request, rootKey: rootKey, completion: completion)
    }

    // MARK: PATCH
    @discardableResult
    func PATCH<T: JSONDeserializable>(_ address: Address, rootKey: String? = nil, parameters: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<T>) -> Void) -> URLSessionDataTask? {
		let request = BasicRequest(method: .PATCH, address: address, parameters: parameters, body: body)
		return loadRequest(request, rootKey: rootKey, completion: completion)
    }

    // MARK: DELETE
    @discardableResult
    func DELETE<T: JSONDeserializable>(_ address: Address, rootKey: String? = nil, parameters: URLParameters? = nil, body: JSONSerializable? = nil, completion: @escaping (ApiResult<T>) -> Void) -> URLSessionDataTask? {
		let request = BasicRequest(method: .DELETE, address: address, parameters: parameters, body: body)
		return loadRequest(request, rootKey: rootKey, completion: completion)
    }

}

typealias ErrorParser = (Any) -> [String]?

// MARK: - Parsing

private extension ApiClient {

	func emptyFetch(request: URLRequest, errorParser: ErrorParser?, completion: @escaping (ApiResult<EmptyResult>) -> Void) -> URLSessionDataTask {
        return fetch(request: request, parseBlock: { (json) -> (resource: EmptyResult?, other: JSONDictionary?) in
            return (resource: EmptyResult(), other: nil)
		}, errorParser: errorParser, completion: completion)
    }

	func fetchResource<T>(request: URLRequest, rootKey: String?, initialization: @escaping (Any) throws -> T, errorParser: ErrorParser?, completion: @escaping (ApiResult<T>) -> Void) -> URLSessionDataTask {
		return fetch(request: request, parseBlock: { (jsonAny) -> (resource: T?, other: JSONDictionary?) in
			var resource: T?
			var other: JSONDictionary?

			if self.developmentModeEnabled {
				do {
					resource = try self.extractResource(jsonAny: jsonAny, rootKey: rootKey, initialization: initialization)
				} catch {
					fatalError("\(error)")
				}
			} else {
				resource = try? self.extractResource(jsonAny: jsonAny, rootKey: rootKey, initialization: initialization)
			}

			if let rootKey = rootKey, let jsonDict = jsonAny as? JSONDictionary {
				var tempOther = jsonDict
				if tempOther[rootKey] != nil {
					tempOther[rootKey] = nil
					if tempOther.keys.count > 0 {
						other = tempOther
					}
				}
			}

			return (resource: resource, other: other)
		}, errorParser: errorParser, completion: completion)
	}

	func extractResource<T>(jsonAny: Any, rootKey: String? = nil, initialization: @escaping (Any) throws -> T) throws -> T {
		var finalJsonAny: Any = jsonAny

		if let rootKey = rootKey {
			if let jsonDict = jsonAny as? JSONDictionary {
				if let extractedJsonAny = jsonDict[rootKey] {
					finalJsonAny = extractedJsonAny
				} else {
					throw Error.missingRootKey(rootKey: rootKey, onDict: jsonDict)
				}
			} else {
				throw Error.invalidTypeForRootKey(type: type(of: jsonAny), rootKey: rootKey)
			}
		}

		return try initialization(finalJsonAny)
	}

}

// MARK: - Fetching

private extension ApiClient {

    func fetch<T>(request: URLRequest, parseBlock: @escaping (Any) -> (resource: T?, other: JSONDictionary?), errorParser: ErrorParser?, completion: @escaping (ApiResult<T>) -> Void) -> URLSessionDataTask {
        ActivityManager.incrementActivityCount()

        let task = jsonTaskWithRequest(request: request as URLRequest) { (json, response, error) in
            DispatchQueue.main.async {
                ActivityManager.decreaseActivityCount()
                if let error = error {
                    self.handleLocalError(error: error, completion: completion)
                } else {
                    if let response = response, let json = json {
						self.handleResponse(response: response, json: json, parseBlock: parseBlock, errorParser: errorParser, completion: completion)
                    } else {
                        completion(.error(.unknownError))
                    }
                }
            }
        }

        task.resume()
        return task
    }

}

// MARK: - Response/Error Handling

extension ApiClient {

	func handleResponse<T>(response: HTTPURLResponse, json: Any, parseBlock: (Any) -> (resource: T?, other: JSONDictionary?), errorParser: ErrorParser?, completion: (ApiResult<T>) -> Void) {
		switch response.statusCode {
		case 200..<300:
			let parseResult = parseBlock(json)
			if let resource = parseResult.resource {
				let headers = response.allHeaderFields as? Dictionary<String, Any>
				let metadata = ResponseMetadata(statusCode: response.statusCode, headers: headers, other: parseResult.other)
				completion(.success(resource: resource, meta: metadata))
			} else {
				print("API CLIENT: WARNING: Couldn't parse the following JSON as a \(T.self)")
				print(json)
				completion(.error(.resourceParseError(resourceType: T.self, json: json)))
			}
		default:
			handleAPIError(response: response, jsonAny: json, errorParser: errorParser, completion: completion)
		}
	}

	func handleAPIError<T>(response: HTTPURLResponse, jsonAny: Any, errorParser: ErrorParser?, completion: (ApiResult<T>) -> Void) {
		let jsonDictionary = jsonAny as? JSONDictionary
		let errorMessages: [String]?

		if let errors = errorParser?(jsonAny) {
			errorMessages = errors
		} else if let error = jsonDictionary?["error"] as? String {
			errorMessages = [error]
		} else if let errors = jsonDictionary?["errors"] as? [String] {
			errorMessages = errors
		} else if let errors = jsonDictionary?["errors"] as? [JSONDictionary] {
			errorMessages = errors.flatMap { return $0["message"] as? String }
		} else {
			errorMessages = nil
		}

		let errorMetadata = ErrorMetadata(statusCode: response.statusCode, errorMessages: errorMessages, userInfo: jsonDictionary)

		switch response.statusCode {
		case 401...403:
			completion(.error(.unauthorized(errorMetadata)))
		case 404:
			completion(.error(.notFound(errorMetadata)))
		case 400...499:
			completion(.error(.clientError(errorMetadata)))
		case 500...599:
			completion(.error(.serverError(errorMetadata)))
		default:
			print("Received HTTP \(response.statusCode), which was not handled")
			completion(.error(.unknownError))
		}
	}

	func handleLocalError<T>(error: Swift.Error, completion: (ApiResult<T>) -> Void) {
		if (error as NSError).code == -999 {
			completion(.error(.cancelled))
		} else {
			completion(.error(.localError(error)))
		}
	}

}

// MARK: - URLSessionDataTask Creation

private extension ApiClient {

	func jsonTaskWithRequest(request: URLRequest, completion: @escaping (Any?, HTTPURLResponse?, Swift.Error?) -> Void) -> URLSessionDataTask {
		var task: URLSessionDataTask!
		task = urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
			self.currentTasks.remove(task)
			let httpResponse = response as? HTTPURLResponse
			if let error = error {
				self.debugLog(msg: "Received an error from HTTP \(request.httpMethod ?? "") to \(request.url?.absoluteString ?? "URL")")
				self.debugLog(msg: "Error: \(error)")
				completion(nil, httpResponse, error)
			} else {
				self.debugLog(msg: "Received HTTP \(httpResponse?.statusCode ?? 0) from \(request.httpMethod ?? "") to \(request.url?.absoluteString ?? "URL")")
				if let data = data {
					do {
						self.debugResponseData(data: data)
						let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
						completion(jsonObject, httpResponse, nil)
					} catch {
						self.debugLog(msg: "Error parsing response as JSON")
						completion(nil, httpResponse, ApiError.jsonParseError(data))
					}
				} else {
					completion(nil, httpResponse, ApiError.emptyResponse)
				}
			}

		})
		currentTasks.insert(task)
		return task
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
