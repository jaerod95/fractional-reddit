//
//  RedditComment.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/23/22.
//

import Foundation

/// Model representing at t1 reddit comment https://www.reddit.com/dev/api/
struct RedditComment: Codable, Identifiable {
    /// ID of the reddit comment. Does not include the tx_ prefix.
    var id: String
    /// Raw text of the reddit comment.
    var body: String?
    //// Raw author username who wrote the comment
    var author: String?
    /// Number of upvotes this reddit comment has.
    var ups: Int
    /// Fully qualified ID of the reddit comment.
    var fullName: String {
        "t1_\(id)"
    }
}
