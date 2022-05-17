//
//  Post.swift
//  MemesViewer
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation

struct Post: Codable {
    var kind: String
    var data: PostData
}

struct PostData: Codable, Identifiable {
    var id: String
    var url: String
    var author: String
    var title: String
    var ups: Int
}
