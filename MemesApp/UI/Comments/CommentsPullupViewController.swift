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
import Toast

class LinkCommentsViewController: PullUpController {
    
    static func makeFromStoryboard(link: RedditLink, delegate: CommentsPullupDelegate) -> LinkCommentsViewController {
        let commentsViewController = UIStoryboard(name: "Comments", bundle: nil).instantiateInitialViewController() as? LinkCommentsViewController ?? LinkCommentsViewController()
        commentsViewController.viewModel.post = link
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
    var viewModel: LinkCommentsViewModel = LinkCommentsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = "\(self.viewModel.post?.numberOfComments ?? 0) Comments"
        self.setupTableView()
        
        
        self.viewModel.fetchComments()
        // sync comments
        self.viewModel.$comments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comments in
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
                
            }.store(in: &cancellables)
        
        // Sync Errors
        self.viewModel.errorMessages.sink { [weak self] message in
            self?.showErrorToast(title: message)
        }.store(in: &cancellables)
        
        self.view.roundCorners(corners: [.topLeft, .topRight], radius: 8)
        self.view.clipsToBounds = true
    }
    
    private func showErrorToast(title: String, subtitle: String? = nil) {
        DispatchQueue.main.async {
            let toast = Toast.default(
                image: UIImage(systemName: "exclamationmark.triangle.fill") ?? UIImage(),
                title: title,
                subtitle: subtitle
            )
            
            toast.show()
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "PostCommentTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: LinkCommentTableViewCell.identifier)
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

// MARK: UITableViewDataSource Conformance

extension LinkCommentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: LinkCommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: LinkCommentTableViewCell.identifier, for: indexPath) as? LinkCommentTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(commentData: viewModel.comments[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDataSourcePrefetching Conformance

extension LinkCommentsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.row > viewModel.comments.count - 20 && viewModel.hasMoreComments {
                self.viewModel.fetchComments()
            }
        }
    }
}

// MARK: CommentsPullupDelegate Implementation

protocol CommentsPullupDelegate {
    func dismissPullup()
}
