//
//  PostsDataController.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import Combine

protocol PostsDataControllerProtocol {
    func getPosts() -> AnyPublisher<[PostData], Error>
    func getCommentsForPost(postID: String) -> AnyPublisher<[PostData], Error>
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
                listing.data.children.compactMap {

                    if $0.data.url.range(of: "(.png|.jpg|.gif)$", options: .regularExpression) != nil {
                        return $0.data
                    }
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getCommentsForPost(postID: String) -> AnyPublisher<[PostData], Error> {
        print("https://www.reddit.com/r/memes/comments/\(postID)")
        guard let url: URL = URL(string: "https://www.reddit.com/r/memes/comments/\(postID).json") else {
            return Fail(error: APIError.invalidRequestError("Unable to parse URL")).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Listing].self, decoder: JSONDecoder())
            .tryMap { listing in
                print(listing)
                return []
            }
            .eraseToAnyPublisher()
    }
}
