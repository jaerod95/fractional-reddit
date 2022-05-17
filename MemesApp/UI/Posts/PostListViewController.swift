//
//  ViewController.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import UIKit
import Combine
import PullUpController

class PostListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: PostListViewModel = PostListViewModel()
    private var cancellables: Set<AnyCancellable> = Set()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        self.viewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { posts in
            self.tableView.reloadData()
        }.store(in: &cancellables)
    }
    
    private func configureTableView() {
        self.tableView.register(UINib(nibName: "PostTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: PostTableViewCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.backgroundColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.viewModel.presentedViewController as? PullUpController {
            self.removePullUpController(vc, animated: true, completion: nil)
        }
    }
}

extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PostTableViewCell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(post: viewModel.posts[indexPath.row], actionsDelegate: self)
        return cell
    }
}

extension PostListViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageHeight = scrollView.frame.size.height
        var currentPage = scrollView.contentOffset.y
        var offset = (scrollView.contentOffset.y - pageHeight / 2) / pageHeight
//        if velocity.y > 0.5 {
//            offset += pageHeight / 2
//        }
        let page = CGFloat(floor(offset) + 1)
        DispatchQueue.main.async {
            scrollView.setContentOffset(CGPoint(x: 0, y: pageHeight * page), animated: true)
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
}

extension PostListViewController: PostActionsDelegate {
    func upvotePressed(post: PostData) {
        print(post)
    }
    
    func sharePressed(post: PostData) {
        print(post)
    }
    
    func commentsPressed(post: PostData) {
        print(post)
        let commentsViewController = UIStoryboard(name: "Comments", bundle: nil).instantiateInitialViewController() as? PostCommentsViewController ?? PostCommentsViewController()
        commentsViewController.viewModel.postId = post.id
        self.viewModel.presentedViewController = commentsViewController
        self.addPullUpController(commentsViewController, initialStickyPointOffset: 500, animated: true)
    }
}
