//
//  CommentsPullupViewController.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import PullUpController
import UIKit

class PostCommentsViewController: PullUpController {
    @IBOutlet private var tableView: UITableView!
    
    var viewModel: PostCommentsViewModel = PostCommentsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PostCommentTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: PostCommentTableViewCell.identifier)
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.viewModel.fetchComments()
    }
    
}

extension PostCommentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PostCommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: PostCommentTableViewCell.identifier, for: indexPath) as? PostCommentTableViewCell else {
            return UITableViewCell()
        }
        cell.configure()
        return cell
    }
    
    
}
