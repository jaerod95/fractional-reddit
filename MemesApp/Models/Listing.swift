//
//  Listing.swift
//  MemesViewer
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation

/// The api type for a reddit listing
struct Listing: Decodable {
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
    case post(PostData)
    case comment(CommentData)
    case none
    
    enum kind: String, Codable {
        case t1
        case t3
        case more
    }
}

/// Provies decoding for dynamic data children types.
extension ListingChild {
    private enum CodingKeys: String, CodingKey {
        case kind, data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(ListingChild.kind.self, forKey: .kind)
        switch kind {
        case .t1:
            let data = try container.decode(CommentData.self, forKey: .data)
            self = .comment(data)
        case .t3:
            let data = try container.decode(PostData.self, forKey: .data)
            self = .post(data)
        default:
            self = .none
        }
    }
}

/// Basic Post Child Type
struct PostData: Codable, Identifiable {
    var id: String
    var url: String
    var author: String
    var title: String
    var ups: Int
    var num_comments: Int
    var likes: Bool?
    
    var fullName: String {
        "t3_\(id)"
    }
}

/// Basic Comment Child Type
struct CommentData: Codable, Identifiable {
    var id: String
    var body: String?
    var author: String?
    var ups: Int
    
    var fullName: String {
        "t1_\(id)"
    }
}
