//
//  CommentsPullupViewController.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import PullUpController
import UIKit
import Combine

class PostCommentsViewController: PullUpController {
    
    static func makeFromStoryboard(post: PostData, delegate: CommentsPullupDelegate) -> PostCommentsViewController {
        let commentsViewController = UIStoryboard(name: "Comments", bundle: nil).instantiateInitialViewController() as? PostCommentsViewController ?? PostCommentsViewController()
        commentsViewController.viewModel.post = post
        commentsViewController.delegate = delegate
        return commentsViewController
    }
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var titleLabel: UILabel!
    @IBAction func onClosePressed(_ sender: UIButton) {
        delegate?.dismissPullup()
    }
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var delegate: CommentsPullupDelegate?
    private let refreshControl = UIRefreshControl()
    var viewModel: PostCommentsViewModel = PostCommentsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = "\(self.viewModel.post?.num_comments ?? 0) Comments"
        self.setupTableView()
        
        
        self.viewModel.fetchComments()
        self.viewModel.$comments
            .receive(on: DispatchQueue.main)
            .sink { comments in
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                
            }.store(in: &cancellables)
        self.view.roundCorners(corners: [.topLeft, .topRight], radius: 8)
        self.view.clipsToBounds = true
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "PostCommentTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: PostCommentTableViewCell.identifier)
        self.tableView.dataSource = self
        self.tableView.prefetchDataSource = self
        self.tableView.allowsSelection = false
        self.tableView.contentInsetAdjustmentBehavior = .never
        // Add refresh
       
        refreshControl.addTarget(self, action: #selector(reloadComments), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    @objc private func reloadComments() {
        self.refreshControl.beginRefreshing()
        viewModel.fetchComments(replacing: true)
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
        cell.configure(comment: viewModel.comments[indexPath.row])
        return cell
    }
}

extension PostCommentsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.row > viewModel.comments.count - 20 && viewModel.hasMoreComments {
                self.viewModel.fetchComments()
            }
        }
    }
}

protocol CommentsPullupDelegate {
    func dismissPullup()
}
