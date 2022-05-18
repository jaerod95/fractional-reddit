//
//  PostTableViewCell.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import UIKit
import Kingfisher
import Lottie

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var upvoteView: AnimationView!
    @IBOutlet private var postImage: AnimatedImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var captionLabel: UILabel!
    @IBOutlet private var authorImage: UIImageView!
    @IBOutlet private var upvoteLabel: UILabel!
    @IBOutlet private var comments: UIButton!
    @IBOutlet private var commentsLabel: UILabel!
    @IBOutlet private var share: UIButton!
    @IBOutlet private var shareLabel: UILabel!
    @IBOutlet weak var upvoteStackView: UIStackView!
    @IBOutlet weak var commentsStackView: UIStackView!
    @IBOutlet weak var shareStackView: UIStackView!
    
    
    private var actionsDelegate: PostActionsDelegate?
    private var post: PostData?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.postImage.kf.setImage(with: URL(string: ""))
        self.upvoteView.currentFrame = 0
    }
    
    func configure(post: PostData, actionsDelegate: PostActionsDelegate) {
        self.actionsDelegate = actionsDelegate
        self.post = post
        
        self.selectionStyle = .none
        self.authorImage.layer.cornerRadius = 24
        
        addShadow(self.upvoteLabel)
        addShadow(self.comments)
        addShadow(self.commentsLabel)
        addShadow(self.share)
        addShadow(self.shareLabel)
        
        self.upvoteStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(upvotePressed)))
        self.commentsStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(commentsPressed)))
        self.shareStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sharePressed)))
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(upvotePressed))
        doubleTap.numberOfTapsRequired = 2
        self.postImage.addGestureRecognizer(doubleTap)
        
        self.upvoteView.animation = Animation.named("upvote", bundle: Bundle.main, subdirectory: nil, animationCache: nil)

        
        // Setup Post Specific Data
        
        guard let url: URL = URL(string: post.url) else {
            return
        }
        
        postImage.kf.setImage(with: url)
        self.authorImage.kf.setImage(with: URL(string: "https://static.vecteezy.com/system/resources/thumbnails/003/337/584/small/default-avatar-photo-placeholder-profile-icon-vector.jpg"))
        self.titleLabel.text = "/u/\(post.author)"
        self.captionLabel.text = post.title
        self.upvoteLabel.text = "\(post.ups)"
        self.commentsLabel.text = "\(post.num_comments)"
        self.backgroundColor = .black
    }
    
    private func addShadow(_ uiView: UIView) {
        uiView.layer.shadowColor = UIColor.black.cgColor
        uiView.layer.shadowOpacity = 0.7
        uiView.layer.shadowOffset = .zero
        uiView.layer.shadowRadius = 8
    }

    @objc func upvotePressed() {
        if upvoteView.currentFrame != 0 {
            self.upvoteView.currentFrame = 0
        } else {
            self.upvoteView.play(toFrame: 34)
        }
        
        guard let postData = self.post else {
            return
        }
        self.actionsDelegate?.upvotePressed(post: postData)
    }
    
    @objc func commentsPressed() {
        guard let postData = self.post else {
            return
        }
        self.actionsDelegate?.commentsPressed(post: postData)
    }
    
    @objc func sharePressed() {
        guard let postData = self.post else {
            return
        }
        self.actionsDelegate?.sharePressed(post: postData)
    }
}

protocol PostActionsDelegate {
    func upvotePressed(post: PostData)
    func commentsPressed(post: PostData)
    func sharePressed(post: PostData)
}
