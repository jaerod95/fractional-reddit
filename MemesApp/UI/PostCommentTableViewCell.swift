////
////  PostCommentTableViewCell.swift
////  MemesApp
////
////  Created by Jason Rodriguez on 5/17/22.
////
//
//import Foundation
//import UIKit
//
//class PostCommentTableViewCell: UITableViewCell {
//    @IBOutlet private var authorImage: UIImageView!
//    @IBOutlet private var authorUsername: UILabel!
//    @IBOutlet private var comment: UILabel!
//    @IBOutlet private var authorImage: UIImageView!
//    @IBOutlet private var upvote: UIButton!
//    @IBOutlet private var comments: UIButton!
//    @IBOutlet private var share: UIButton!
//    
//    private var actionsDelegate: PostActionsDelegate?
//    private var post: PostData?
//    
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        self.postImage.image = nil
//    }
//    
//    func configure(post: PostData, actionsDelegate: PostActionsDelegate) {
//        self.actionsDelegate = actionsDelegate
//        self.post = post
//        guard let url: URL = URL(string: post.url) else {
//            return
//        }
//        if post.url.hasSuffix(".gif") {
//            let loader = UIActivityIndicatorView(style: .white)
//            postImage.setGifFromURL(url, customLoader: loader)
//        } else {
//            postImage.kf.setImage(with: url)
//        }
//        self.titleLabel.text = post.author
//        self.captionLabel.text = post.title
//        self.comments.addTarget(self, action: #selector(commentsPressed), for: .touchUpInside)
//        self.backgroundColor = .black
//    }
//}
