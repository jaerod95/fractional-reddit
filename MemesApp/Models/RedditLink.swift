//
//  Link.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/23/22.
//

import Foundation

/// Model representing at t3 reddit link https://www.reddit.com/dev/api/
struct RedditLink: Decodable, Identifiable {
    /// ID of the reddit link. Does not include the tx_ prefix.
    var id: String
    /// URL String to the reddit link content.
    var url: String
    /// Author username of the reddit link.
    var author: String
    /// Title of the reddit link.
    var title: String
    /// Number of upvotes this reddit link has.
    var ups: Int
    /// Total number of comments this link has.
    var numberOfComments: Int
    /// Fully qualified ID of the reddit link.
    var fullName: String {
        "t3_\(id)"
    }
    
    /// Custom Coding keys for Decodable conformance
    private enum CodingKeys: String, CodingKey {
        case id, url, author, title, ups
        case numberOfComments = "num_comments"
    }
    
    /// Initializes a RedditLink from a Decoder
    /// - Parameter decoder: Decoder containing a reddit link keyed container
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        self.author = try container.decodeIfPresent(String.self, forKey: .author) ?? ""
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.ups = try container.decodeIfPresent(Int.self, forKey: .ups) ?? 0
        self.numberOfComments = try container.decodeIfPresent(Int.self, forKey: .numberOfComments) ?? 0
    }
}
