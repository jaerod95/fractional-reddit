//
//  PostCommentTableViewCell.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import UIKit
import Kingfisher
import Lottie

class PostCommentTableViewCell: UITableViewCell {
    @IBOutlet private var authorImage: UIImageView!
    @IBOutlet private var authorUsername: UILabel!
    @IBOutlet private var comment: UILabel!
    @IBOutlet weak var commentUpvoteView: AnimationView!
    @IBOutlet weak var commentUpvoteLabel: UILabel!
    
    private var actionsDelegate: PostActionsDelegate?
    private var commentData: RedditComment?
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(commentData: RedditComment) {
        self.commentData = commentData
        // Configure author
        self.commentUpvoteView.animation = Animation.named("upvote", bundle: Bundle.main, subdirectory: nil, animationCache: nil)
        self.commentUpvoteLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(upvoted)))
        self.commentUpvoteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(upvoted)))
        
        
        self.authorImage.layer.cornerRadius = 16
        self.authorImage.kf.setImage(with: URL(string: "https://static.vecteezy.com/system/resources/thumbnails/003/337/584/small/default-avatar-photo-placeholder-profile-icon-vector.jpg"))
        self.authorUsername.text = commentData.author
        self.comment.text = commentData.body
        self.commentUpvoteLabel.text = "\(commentData.ups)"
    }
    
    @objc private func upvoted() {
        if commentUpvoteView.currentFrame != 0 {
            self.commentUpvoteView.currentFrame = 0
            self.commentUpvoteLabel.text = "\(commentData?.ups ?? 0)"
        } else {
            self.commentUpvoteView.play(toFrame: 34)
            self.commentUpvoteLabel.text = "\(commentData?.ups ?? 0 + 1)"
        }
    }
}
