//
//  CommentsPullupViewController.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import PullUpController
import UIKit

//class PostCommentsViewController: PullUpController {
//    @IBOutlet private var tableView: UITableView!
//    
//    private var viewModel: PostCommentsViewModel = PostCommentsViewModel()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.dataSource = self
//    }
//    
//}
//
//extension PostCommentsViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.comments.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell: PostTableViewCell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
//            return UITableViewCell()
//        }
//        cell.configure(post: viewModel.posts[indexPath.row], actionsDelegate: self)
//        return cell
//    }
//    
//    
//}
