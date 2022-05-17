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

class PostListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: PostListViewModel = PostListViewModel()
    private var cancellables: Set<AnyCancellable> = Set()
    private var currentPage: Int = 0
    private let refreshControl = UIRefreshControl()
    
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
        refreshControl.addTarget(self, action: #selector(reloadComments), for: .valueChanged)
        refreshControl.tintColor = .white
        self.tableView.refreshControl = refreshControl
    }
    
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
}

extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismissPullup()
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
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
}

extension PostListViewController: PostActionsDelegate {
    func upvotePressed(post: PostData) {
        print(post)
    }
    
    func sharePressed(post: PostData) {
        guard let url = URL(string: post.url) else {
            let toast = Toast.default(
                image: UIImage(systemName: "exclamationmark.triangle.fill") ?? UIImage(),
                title: "Something went wrong",
                subtitle: "try again later"
            )
            toast.show()
            return
        }
        let sharableItems = [post.title, url] as [Any]
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
    
    func commentsPressed(post: PostData) {
        let vc = PostCommentsViewController.makeFromStoryboard(post: post, delegate: self)
        self.viewModel.presentedViewController = vc
        Haptic.light()
        self.addPullUpController(vc, initialStickyPointOffset: 500, animated: true)
    }
}

extension PostListViewController: CommentsPullupDelegate {
    func dismissPullup() {
        if let vc = self.viewModel.presentedViewController as? PullUpController {
            Haptic.light()
            self.removePullUpController(vc, animated: true, completion: nil)
        }
    }
}
