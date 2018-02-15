//
//  Request.swift
//  Analytics
//
//  Created by Daniel Lozano Valdés on 2/13/18.
//

import Foundation

public protocol Request {

	var method: HTTPMethod { get }

	var address: Address { get }

	var parameters: URLParameters? { get }

	var body: JSONSerializable? { get }

}

public enum Address {

	case absolute(String)
	case relative(host: String, path: String)

}

struct BasicRequest: Request {

	let method: HTTPMethod
	let address: Address
	let parameters: URLParameters?
	let body: JSONSerializable?

}

public extension Request {

	var fullAddress: String {
		switch address {
		case let .absolute(fullAddress):
			return fullAddress
		case let .relative(host, path):
			var fullAddress = host
			if fullAddress.last != "/" {
				fullAddress += "/"
			}

			var tempPath = path
			if tempPath.first == "/" {
				tempPath.removeFirst()
			}

			fullAddress += tempPath
			return fullAddress
		}
	}

	var url: URL? {
		guard let escaped = fullAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			return nil
		}

		guard let parameters = parameters else {
			return URL(string: escaped)
		}

		guard let url = URL(string: escaped), var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			return nil
		}

		let queryItems: [URLQueryItem] = parameters.map { (key, value) -> URLQueryItem in
			return URLQueryItem(name: key, value: value)
		}

		components.queryItems = queryItems
		return components.url
	}

	var urlRequest: URLRequest? {
		guard let url = url else {
			return nil
		}

		guard method != .GET else {
			return URLRequest(url: url)
		}

		do {
			var request = URLRequest(url: url)
			request.httpMethod = method.rawValue
			if let body = body {
				let json = body.json
				let bodyData = try JSONSerialization.data(withJSONObject: json, options: [])
				request.httpBody = bodyData
			}
			return request
		} catch {
			return nil
		}
	}

}
