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
    @IBOutlet private var authorImage: UIImageView!
    @IBOutlet private var upvote: UIButton!
    @IBOutlet private var upvoteLabel: UILabel!
    @IBOutlet private var comments: UIButton!
    @IBOutlet private var commentsLabel: UILabel!
    @IBOutlet private var share: UIButton!
    @IBOutlet private var shareLabel: UILabel!
    
    
    private var actionsDelegate: PostActionsDelegate?
    private var post: PostData?
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.postImage.image = nil
    }
    
    func configure(post: PostData, actionsDelegate: PostActionsDelegate) {
        self.actionsDelegate = actionsDelegate
        self.post = post
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
        self.upvoteLabel.text = "\(post.ups)"
        self.commentsLabel.text = "\(post.num_comments)"
        self.comments.addTarget(self, action: #selector(commentsPressed), for: .touchUpInside)
        self.backgroundColor = .black
    }

    @objc func commentsPressed() {
        guard let postData = self.post else {
            return
        }
        self.actionsDelegate?.commentsPressed(post: postData)
    }
}

protocol PostActionsDelegate {
    func commentsPressed(post: PostData)
}
