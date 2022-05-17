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
    func getPosts() -> AnyPublisher<[PostData], Error>
    func getCommentsForPost(postID: String) -> AnyPublisher<[CommentData], Error>
}

enum APIError: LocalizedError {
    case invalidRequestError(String)
}

struct PostsDataController: PostsDataControllerProtocol {
    func getPosts() -> AnyPublisher<[PostData], Error> {
        guard let url: URL = URL(string: "https://www.reddit.com/r/memes.json") else {
            return Fail(error: APIError.invalidRequestError("Unable to parse URL")).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Listing.self, decoder: JSONDecoder())
            .tryMap { listing in
                return listing.data.children.compactMap {
                    print($0)
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
    
    func getCommentsForPost(postID: String) -> AnyPublisher<[CommentData], Error> {
        print("https://www.reddit.com/r/memes/comments/\(postID).json")
        
        guard let url: URL = URL(string: "https://www.reddit.com/r/memes/comments/\(postID).json") else {
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
    
    func getoAuthToken() {
        let user = "t6u5k2GJ5kQhN4_zk6ZTHg"
        let password = "CMSKS9-8XekqFJjZz80LnB3B6wLd3g"
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers: HTTPHeaders = ["Authorization": "Basic \(base64Credentials)"]
        let params = ["grant_type": "password", "username": "AgileBasis", "password": "tygkiq-zukfa8-goWkoq"]
        var url = URLComponents(string: "https://www.google.com/search/")!
        
        url.queryItems = [
            URLQueryItem(name: "grant_type", value: "password"),
            URLQueryItem(name: "username", value: "AgileBasis"),
            URLQueryItem(name: "password", value: "tygkiq-zukfa8-goWkoq")
        ]
        do {
        let urlRequest = try URLRequest(url: url.url!, method: .post, headers: headers)
        URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: [Listing].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
        } catch {
            print("ERROR! Couldn get the token")
        }
    }
}
