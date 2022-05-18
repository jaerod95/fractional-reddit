//
//  PostListViewModel.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import UIKit
import Combine

protocol PostListViewModelProtocol: ObservableObject {
    var posts: [PostData] { get }
    var hasMorePosts: Bool { get }
    func fetchPosts(replacing: Bool)
}

class PostListViewModel: ObservableObject, PostListViewModelProtocol {
    private var cancellables: Set<AnyCancellable> = Set()
    private var postsDataController: PostsDataControllerProtocol = PostsDataController()
    private var isFetching: Bool = false
    @Published var posts: [PostData] = []
    var hasMorePosts: Bool = true
    var presentedViewController: UIViewController?
    
    init() {
        fetchPosts()
    }
    
    func fetchPosts(replacing: Bool = false) {
        if isFetching {
            return
        }
        isFetching = true
        var after: String?
        if !replacing {
            if let lastPost = self.posts.last {
                after = lastPost.fullName
            }
        }
        postsDataController.getPosts(after: after).sink { completion in
            self.isFetching = false
        } receiveValue: { newPosts in
            if replacing {
                self.posts = newPosts
            } else {
                self.posts += newPosts
            }
            self.hasMorePosts = newPosts.count > 0
        }
        .store(in: &cancellables)
    }
}
