//
//  RedditListing.swift
//  MemesViewer
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation

/// The api type for a reddit listing
struct RedditListing: Decodable {
    var data: ListingData
}

/// The api data of a reddit listing
struct ListingData: Decodable {
    var after: String?
    var before: String?
    var dist: Int?
    var children: [ListingChild]
}

/// Dynamic reddit child type. Many types can be used in the same children array
enum ListingChild: Decodable {
    case link(RedditLink)
    case comment(RedditComment)
    case none
    
    enum kind: String, Codable {
        case t1
        case t3
        case more
    }
    
    private enum CodingKeys: String, CodingKey {
        case kind, data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(ListingChild.kind.self, forKey: .kind)
        switch kind {
        case .t1:
            let data = try container.decode(RedditComment.self, forKey: .data)
            self = .comment(data)
        case .t3:
            let data = try container.decode(RedditLink.self, forKey: .data)
            self = .link(data)
        default:
            self = .none
        }
    }
}

