//
//  PostTableViewCell.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import UIKit
import SwiftyGif
import Kingfisher

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet private var postImage: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var captionLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.postImage.image = nil
    }
    
    func configure(post: PostData) {
        guard let url: URL = URL(string: post.url) else {
            return
        }
        if post.url.hasSuffix(".gif") {
            let loader = UIActivityIndicatorView(style: .white)
            postImage.setGifFromURL(url, customLoader: loader)
        } else {
            postImage.kf.setImage(with: url)
        }
        self.titleLabel.text = post.author
        self.captionLabel.text = post.title
        self.backgroundColor = .black
    }
}