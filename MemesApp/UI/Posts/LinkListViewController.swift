//
//  ViewController.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import UIKit
import Combine
import PullUpController
import Toast

class LinkListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: LinkListViewModel = LinkListViewModel()
    private var cancellables: Set<AnyCancellable> = Set()
    private var currentPage: Int = 0
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        // Sync posts
        self.viewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posts in
                self?.tableView.reloadData()
            }.store(in: &cancellables)
        // Sync Errors
        self.viewModel.errorMessages.sink { [weak self] message in
            self?.showErrorToast(title: message)
        }.store(in: &cancellables)
    }
    
    /// Prepares tableview delegates and default look/feel
    private func configureTableView() {
        self.tableView.register(UINib(nibName: "PostTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: LinkTableViewCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.prefetchDataSource = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.backgroundColor = .black
        refreshControl.addTarget(self, action: #selector(reloadComments), for: .valueChanged)
        refreshControl.tintColor = .white
        self.tableView.refreshControl = refreshControl
    }
    
    /// Reloads All comments
    @objc private func reloadComments() {
        self.refreshControl.beginRefreshing()
        viewModel.fetchPosts(replacing: true)
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
}

// MARK: UITableViewDelegate Conformance

extension LinkListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismissPullup()
    }
}

// MARK: UITableViewDataSource Conformance

extension LinkListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: LinkTableViewCell = tableView.dequeueReusableCell(withIdentifier: LinkTableViewCell.identifier, for: indexPath) as? LinkTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(link: viewModel.posts[indexPath.row], actionsDelegate: self)
        return cell
    }
}

// MARK: UITableViewDataSourcePrefetching Conformance

extension LinkListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if indexPath.row > viewModel.posts.count - 20 && viewModel.hasMorePosts {
                self.viewModel.fetchPosts()
            }
        }
    }
    
    
}

// MARK: UIScrollViewDelegate Conformance

extension LinkListViewController: UIScrollViewDelegate {
    
    /// Used to make scrolling feel more natural.
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageHeight = scrollView.frame.size.height
        
        let offset = (scrollView.contentOffset.y - pageHeight / 2) / pageHeight
        var page = CGFloat(floor(offset) + 1)
        if velocity.y > 0.5 && viewModel.posts.count > currentPage + 1 {
            page = CGFloat(currentPage + 1)
        } else if velocity.y < -0.5 && currentPage - 1 >= 0 {
            page = CGFloat(currentPage - 1)
        }
        
        
        self.currentPage = Int(page)
        DispatchQueue.main.async {
            scrollView.setContentOffset(CGPoint(x: 0, y: pageHeight * page), animated: true)
        }
    }
}

// MARK: LinkActionsDelegate Conformance

extension LinkListViewController: LinkActionsDelegate {
    func upvotePressed(link: RedditLink) {
        print(link)
        // TODO: Call Upvote API Endpoint from viewModel
    }
    
    /// Shares the URL and title of the post
    /// - Parameter post: post to share
    func sharePressed(link: RedditLink) {
        guard let url = URL(string: link.url) else {
            showErrorToast(title: "Something went wrong", subtitle: "try again later")
            return
        }
        let sharableItems = [link.title, url] as [Any]
        let ac = UIActivityViewController(activityItems: sharableItems, applicationActivities: nil)
        ac.completionWithItemsHandler = { activity, success, items, error in
            if success {
                let toast = Toast.text("Your post was shared")
                toast.show(haptic: .success)
            }
        }
        DispatchQueue.main.async {
            self.present(ac, animated: true)
        }
    }
    
    /// Shows the comments pullup
    /// - Parameter post: shows the comments pullup
    func commentsPressed(link: RedditLink) {
        let vc = LinkCommentsViewController.makeFromStoryboard(link: link, delegate: self)
        self.viewModel.presentedViewController = vc
        Haptic.light()
        self.addPullUpController(vc, initialStickyPointOffset: 500, animated: true)
    }
}

// MARK: UITableViewDataSource Implementation

extension LinkListViewController: CommentsPullupDelegate {
    /// Dismisses the comments pullup if it is shown
    func dismissPullup() {
        if let vc = self.viewModel.presentedViewController as? PullUpController {
            Haptic.light()
            self.removePullUpController(vc, animated: true, completion: nil)
        }
    }
}
