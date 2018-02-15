//
//  Resource.swift
//  Analytics
//
//  Created by Daniel Lozano Valdés on 2/14/18.
//

import Foundation

public protocol Resource {

	associatedtype Model
	typealias ErrorDescription = String

	var request: Request { get }

	var rootKey: String? { get }

	var parser: ((Any) throws -> Model)  { get }

	var errorParser: ((Any) -> [ErrorDescription]?)? { get }

}

public struct BasicResource<Model>: Resource {

	public typealias ParseBlock = ((Any) throws -> Model)
	public typealias ErrorParseBlock = ((Any) -> [Resource.ErrorDescription]?)

	public var request: Request

	public var rootKey: String?

	public var parser: ParseBlock

	public var errorParser: ErrorParseBlock?

	init(request: Request, rootKey: String? = nil, parser: @escaping ParseBlock, errorParser: ErrorParseBlock? = nil) {
		self.request = request
		self.rootKey = rootKey
		self.parser = parser
		self.errorParser = errorParser
	}

}
