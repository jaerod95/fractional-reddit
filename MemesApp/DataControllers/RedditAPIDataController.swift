//
//  RedditAPIDataController.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import Combine
import Alamofire

protocol RedditAPIDataControllerProtocol {
    /// Fetches Links from a particular sub reddit
    /// - Parameter after: The Link to request links after
    /// - Returns: Publisher with Link Data
    func getLinks(after: String?) -> AnyPublisher<[RedditLink], APIDataController.APIError>
    /// Fetches comments for Link
    /// - Parameters:
    ///   - linkID: Link to Fetch Comments for
    ///   - after: the last comment you should fetch after
    /// - Returns: Publisher with array of comment Data
    func getCommentsForLink(linkID: String, after: String?) -> AnyPublisher<[RedditComment], APIDataController.APIError>
    /// Generates a REddit Auth Token
    /// - Returns: Publisher with the auth token or an error.
    func getAuthToken() -> AnyPublisher<RedditAPIDataController.RedditAPIAccessToken, APIDataController.APIError>
}

/// Handles Fetching Listings off the Reddit API
class RedditAPIDataController: APIDataController, RedditAPIDataControllerProtocol {
    /// Stored Access Token to use between requests
    private var accessToken: RedditAPIAccessToken?
    
    /// Fetches Links from a particular sub reddit
    /// - Parameter after: The Link to request links after
    /// - Returns: Publisher with Link Data
    func getLinks(after: String? = nil) -> AnyPublisher<[RedditLink], APIError> {
        var urlComponents: URLComponents? = URLComponents(string: "https://www.reddit.com/r/memes.json")
        urlComponents?.queryItems = [
            URLQueryItem(name: "after", value: after),
            URLQueryItem(name: "limit", value: "25"),
        ]
        
        guard let request: URLRequest = try? getURLRequest(urlComponents) else {
            return Fail(error: APIError.invalidRequestError).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .retry(3)
            .map(\.data)
            .decode(type: RedditListing.self, decoder: JSONDecoder())
            .tryMap { listing in
                return listing.data.children.compactMap {
                    switch ($0) {
                    case .link(let linkData):
                        if linkData.url.range(of: "(.png|.jpg|.gif)$", options: .regularExpression) != nil {
                            return linkData
                        }
                    default:
                        break
                    }
                    return nil
                }
            }
            .mapError(handleErrors)
            .eraseToAnyPublisher()
    }
    
    /// Fetches comments for Link
    /// - Parameters:
    ///   - linkID: Link to Fetch Comments for
    ///   - after: the last comment you should fetch after
    /// - Returns: Publisher with array of comment Data
    func getCommentsForLink(linkID: String, after: String? = nil) -> AnyPublisher<[RedditComment], APIError> {
        var urlComponents = URLComponents(string: "https://www.reddit.com/r/memes/comments/\(linkID).json")
        urlComponents?.queryItems = [
            URLQueryItem(name: "after", value: after),
            URLQueryItem(name: "limit", value: "25"),
        ]
        
        guard let request: URLRequest = try? getURLRequest(urlComponents) else {
            return Fail(error: APIError.invalidRequestError).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .retry(3)
            .map(\.data)
            .decode(type: [RedditListing].self, decoder: JSONDecoder())
            .tryMap { listing in
                listing.last?.data.children.compactMap {
                    switch ($0) {
                    case .comment(let comment):
                        return comment
                    default:
                        return nil
                    }
                } ?? []
            }
            .mapError(handleErrors)
            .eraseToAnyPublisher()
    }
    
    /// Upvotes a particular Link
    /// - Parameter linkFullName: fullName of the link to upvote
    /// - Returns: Publisher with bool of whether it was a success or not.
    func upvoteLink(linkFullName: String) -> AnyPublisher<Bool, APIError> {
        return getAuthToken()
            .flatMap { [weak self] token -> AnyPublisher<Bool, APIError> in
                let headers: HTTPHeaders = ["Authorization": "Bearer \(token.accessToken)"]
                var url = URLComponents(string: "https://www.oauth.reddit.com/api/vote")
                url?.queryItems = [
                    URLQueryItem(name: "dir", value: "1"),
                    URLQueryItem(name: "id", value: linkFullName),
                    
                ]
                
                guard let request = try? self?.getURLRequest(url, method: .post, headers: headers) else {
                    return Fail(error: APIError.invalidRequestError).eraseToAnyPublisher()
                }
                
                guard let errorHandler = self?.handleErrors else {
                    return Fail(error: APIError.invalidRequestError).eraseToAnyPublisher()
                }
                        
                return URLSession.shared.dataTaskPublisher(for: request)
                    .map(\.data)
                    .decode(type: String.self, decoder: JSONDecoder())
                    .tryMap {
                        print($0)
                        return true
                    }
                    .mapError(errorHandler)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// TODO: This would be a major blocker for getting the app ready for production. Simply put, you just can't throw plain text secrets into your code. Ideally i'd replace this with one of the two options. Both apply one simple policy: Don't store secrets on this client. Instead you can:
    /// 1. Authenticate via oauth directly with reddit. Then you can have a generated token passed back during runtime.
    /// 2. Proxy our requests through our own server and do our secrets handling there.
    /// 
    /// Generates a reddit Auth Token
    /// - Returns: Publisher with the auth token or an error.
    func getAuthToken() -> AnyPublisher<RedditAPIAccessToken, APIError> {
        if let token = accessToken {
            return Just(token)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
        
        let user = "some_user"
        let password = "some_password"
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers: HTTPHeaders = ["Authorization": "Basic \(base64Credentials)"]
        var url = URLComponents(string: "https://www.reddit.com/api/v1/access_token")
        
        url?.queryItems = [
            URLQueryItem(name: "grant_type", value: "password"),
            URLQueryItem(name: "username", value: "username_secrets"),
            URLQueryItem(name: "password", value: "some_password_from_secrets")
        ]
        
        guard let request = try? getURLRequest(url, method: .post, headers: headers) else {
            return Fail(error: APIError.invalidRequestError).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: RedditAPIAccessToken.self, decoder: JSONDecoder())
            .map { token in
                self.accessToken = token
                return token
            }
            .mapError(handleErrors)
            .eraseToAnyPublisher()
    }
}

// MARK: RedditAPIAccessToken Implementation

extension RedditAPIDataController {
    /// Model for reddit API Token
    struct RedditAPIAccessToken: Codable {
        /// Actual String access token value.
        var accessToken: String
        /// The type of access token.
        var tokenType: String
        /// Number of seconds from when the token was expired that this token will expire at.
        var expiresIn: Int
        /// Access scope this token has.
        var scope: String
        /// When this token was created. This is set when we get the token, not when it was created by the server.
        var createdAt: Date = Date()
        /// Helper to know whether the token is experied or not.
        var isExpired: Bool {
            // TODO: add expiration here
            return false
        }
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case expiresIn = "expires_in"
            case scope
        }
    }
}
