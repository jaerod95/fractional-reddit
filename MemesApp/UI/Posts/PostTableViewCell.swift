//
//  PostTableViewCell.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import UIKit
import Kingfisher

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var actionsBlurredBackground: UIView!
    @IBOutlet private var postImage: AnimatedImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var captionLabel: UILabel!
    @IBOutlet private var authorImage: UIImageView!
    @IBOutlet private var upvote: UIButton!
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
    }
    
    func configure(post: PostData, actionsDelegate: PostActionsDelegate) {
        self.actionsDelegate = actionsDelegate
        self.post = post
        
        self.selectionStyle = .none
        
        self.upvoteStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(upvotePressed)))
        self.commentsStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(commentsPressed)))
        self.shareStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sharePressed)))
        
        addShadow(self.upvote)
        addShadow(self.upvoteLabel)
        addShadow(self.comments)
        addShadow(self.commentsLabel)
        addShadow(self.share)
        addShadow(self.shareLabel)
        
        guard let url: URL = URL(string: post.url) else {
            return
        }
        
        postImage.kf.setImage(with: url)
        self.authorImage.kf.setImage(with: URL(string: "https://static.vecteezy.com/system/resources/thumbnails/003/337/584/small/default-avatar-photo-placeholder-profile-icon-vector.jpg"))
        self.authorImage.layer.cornerRadius = 24
        self.titleLabel.text = post.author
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
