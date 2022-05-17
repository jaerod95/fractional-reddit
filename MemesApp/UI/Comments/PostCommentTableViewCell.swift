//
//  PostCommentTableViewCell.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import UIKit
import Kingfisher

class PostCommentTableViewCell: UITableViewCell {
    @IBOutlet private var authorImage: UIImageView!
    @IBOutlet private var authorUsername: UILabel!
    @IBOutlet private var comment: UILabel!
    
    private var actionsDelegate: PostActionsDelegate?
    private var post: PostData?
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(comment: CommentData) {
        // Configure author
        self.authorImage.layer.cornerRadius = 16
        self.authorImage.kf.setImage(with: URL(string: "https://static.vecteezy.com/system/resources/thumbnails/003/337/584/small/default-avatar-photo-placeholder-profile-icon-vector.jpg"))
        self.authorUsername.text = comment.author
        self.comment.text = comment.body
    }
}
