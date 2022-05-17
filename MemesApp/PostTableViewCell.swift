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
    @IBOutlet private var upvote: VerticalButton!
    @IBOutlet private var comments: VerticalButton!
    @IBOutlet private var share: VerticalButton!
    
    
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

class VerticalButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentHorizontalAlignment = .left
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerButtonImageAndTitle()
    }
    
    private func centerButtonImageAndTitle() {
        let titleSize = self.titleLabel?.frame.size ?? .zero
        let imageSize = self.imageView?.frame.size  ?? .zero
        let spacing: CGFloat = 6.0
        self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing),left: 0, bottom: 0, right:  -titleSize.width)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0)
    }
}
