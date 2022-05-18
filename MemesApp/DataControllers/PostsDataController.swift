//
//  PostsDataController.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import Combine
import Alamofire

protocol PostsDataControllerProtocol {
    var accessToken: AccessToken? { get }
    func getPosts(after: String?) -> AnyPublisher<[PostData], Error>
    func getCommentsForPost(postID: String, after: String?) -> AnyPublisher<[CommentData], Error>
    func getAuthToken() -> AnyPublisher<AccessToken , Error>
}

/// List of Potential API Errors
enum APIError: LocalizedError {
    case invalidRequestError(String)
}

/// Handles Fetching Listings off the Reddit API
class PostsDataController: PostsDataControllerProtocol {
    /// Stored Access Token to use between requests
    var accessToken: AccessToken?
    
    /// Fetches Links from a particular sub reddit
    /// - Parameter after: The Link to request links after
    /// - Returns: Publisher with Link Data
    func getPosts(after: String? = nil) -> AnyPublisher<[PostData], Error> {
        var urlComponents = URLComponents(string: "https://www.reddit.com/r/memes.json")
        urlComponents?.queryItems = [
            URLQueryItem(name: "after", value: after),
            URLQueryItem(name: "limit", value: "25"),
        ]
        
        guard let url: URL = urlComponents?.url else {
            return Fail(error: APIError.invalidRequestError("Unable to parse URL")).eraseToAnyPublisher()
        }
        
        guard let urlRequest: URLRequest = try? URLRequest(url: url, method: .get, headers: nil) else {
            return Fail(error: APIError.invalidRequestError("Unable to parse URL")).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: Listing.self, decoder: JSONDecoder())
            .tryMap { listing in
                return listing.data.children.compactMap {
                    switch ($0) {
                    case .post(let postData):
                        if postData.url.range(of: "(.png|.jpg|.gif)$", options: .regularExpression) != nil {
                            return postData
                        }
                    default:
                        break
                    }
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// Fetches comments for Link
    /// - Parameters:
    ///   - postID: Post to Fetch Comments for
    ///   - after: the last comment you should fetch after
    /// - Returns: Publisher with array of comment Data
    func getCommentsForPost(postID: String, after: String? = nil) -> AnyPublisher<[CommentData], Error> {
        
        var urlComponents = URLComponents(string: "https://www.reddit.com/r/memes/comments/\(postID).json")
        urlComponents?.queryItems = [
            URLQueryItem(name: "after", value: after),
            URLQueryItem(name: "limit", value: "25"),
        ]
        
        guard let url: URL = urlComponents?.url else {
            return Fail(error: APIError.invalidRequestError("Unable to parse URL")).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Listing].self, decoder: JSONDecoder())
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
            .eraseToAnyPublisher()
    }
    
    /// Upvotes a particular Link
    /// - Parameter postFullName: fullName of the link to upvote
    /// - Returns: Publisher with bool of whether it was a success or not.
    func upvotePost(postFullName: String) -> AnyPublisher<Bool, Error> {
        return getAuthToken()
            .flatMap { token -> AnyPublisher<Bool, Error> in
                let headers: HTTPHeaders = ["Authorization": "Bearer \(token.accessToken)"]
                var url = URLComponents(string: "https://www.oauth.reddit.com/api/vote")
                url?.queryItems = [
                    URLQueryItem(name: "dir", value: "1"),
                    URLQueryItem(name: "id", value: postFullName),
                    
                ]
                guard let url = url?.url else {
                    return Fail(error: APIError.invalidRequestError("Unable to parse URL")).eraseToAnyPublisher()
                }
                
                guard let urlRequest = try? URLRequest(url: url, method: .post, headers: headers) else {
                    return Fail(error: APIError.invalidRequestError("Unable to parse URL")).eraseToAnyPublisher()
                }
                return URLSession.shared.dataTaskPublisher(for: urlRequest)
                    .map(\.data)
                    .decode(type: String.self, decoder: JSONDecoder())
                    .tryMap {
                        print($0)
                        return true
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// Generates a REddit Auth Token
    /// - Returns: Publisher with the auth token or an error.
    func getAuthToken() -> AnyPublisher<AccessToken, Error> {
        if let token = accessToken {
            return Just(token)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let user = "t6u5k2GJ5kQhN4_zk6ZTHg"
        let password = "CMSKS9-8XekqFJjZz80LnB3B6wLd3g"
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers: HTTPHeaders = ["Authorization": "Basic \(base64Credentials)"]
        var url = URLComponents(string: "https://www.reddit.com/api/v1/access_token")
        
        url?.queryItems = [
            URLQueryItem(name: "grant_type", value: "password"),
            URLQueryItem(name: "username", value: "AgileBasis"),
            URLQueryItem(name: "password", value: "tygkiq-zukfa8-goWkoq")
        ]
        
        guard let url = url?.url else {
            return Fail(error: APIError.invalidRequestError("Unable to parse URL")).eraseToAnyPublisher()
        }
        
        guard let urlRequest = try? URLRequest(url: url, method: .post, headers: headers) else {
            return Fail(error: APIError.invalidRequestError("Unable to parse URL")).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: AccessToken.self, decoder: JSONDecoder())
            .map { token in
                self.accessToken = token
                return token
            }
            .eraseToAnyPublisher()
    }
}
