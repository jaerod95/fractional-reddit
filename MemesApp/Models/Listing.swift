//
//  Listing.swift
//  MemesViewer
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation

struct Listing: Codable {
    var data: ListingData
}

struct ListingData: Codable {
    var after: String?
    var before: String?
    var dist: Int
    var children: [Post]
    
}
