//
//  ViewController.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import UIKit
import Combine

class PostListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: PostListViewModel = PostListViewModel()
    private var cancellables: Set<AnyCancellable> = Set()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: PostTableViewCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.viewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { posts in
            self.tableView.reloadData()
        }.store(in: &cancellables)
        
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
}

extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PostTableViewCell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(post: viewModel.posts[indexPath.row])
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

