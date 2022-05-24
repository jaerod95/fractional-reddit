//
//  APIDataController.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/23/22.
//

import Foundation
import Alamofire

/// Base Class for an API Data Controller. This class can be resused to point at any API and provides a few helper methods and types.
class APIDataController {
    
    /// Creates a new URLRequest. Throws an `APIError` if it can't create the request.
    /// - Parameters:
    ///   - url: URL to create the request for.
    ///   - method: The HTTP Method to use. Defaults to .get
    ///   - headers: Headers to pass into the request. Defaults to nil.
    /// - Returns: A Created URLRequest.
    func getURLRequest(_ url: URLComponents?, method: HTTPMethod = .get, headers: HTTPHeaders? = nil) throws -> URLRequest {
        guard let url = url, let urlRequest: URLRequest = try? URLRequest(url: url, method: method, headers: headers) else {
            throw APIError.invalidRequestError
        }
        
        return urlRequest
    }
    
    /// Generic Error Handler that converts common Errors to APIError
    /// - Parameter error: Raw error passed into converter
    /// - Returns: An APIError that matches the situation
    func handleErrors(error: Error) -> APIError {
        switch error {
        case is DecodingError:
            return .decodingFailed
        default:
            return .invalidRequestError
        }
    }
}

// MARK: APIError Implementation

extension APIDataController {
    /// List of Potential API Errors
    enum APIError: LocalizedError {
        /// Generic Error when some bad request happens.
        case invalidRequestError
        /// Error sent when a 429 Error is sent from the API.
        case rateLimited
        /// Error sent when unable to decode data
        case decodingFailed
    }
}
