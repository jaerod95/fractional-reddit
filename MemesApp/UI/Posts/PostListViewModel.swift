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
    func fetchPosts(replacing: Bool)
}

class PostListViewModel: ObservableObject, PostListViewModelProtocol {
    private var cancellables: Set<AnyCancellable> = Set()
    private var postsDataController: PostsDataControllerProtocol = PostsDataController()
    @Published var posts: [PostData] = []
    var presentedViewController: UIViewController?
    
    init() {
        fetchPosts()
    }
    
    func fetchPosts(replacing: Bool = false) {
        var after: String?
        if !replacing {
            after = self.posts.last?.id
        }
        postsDataController.getPosts(after: after, replacing: replacing).sink { completion in
            print(completion)
        } receiveValue: { posts in
            print(posts)
            self.posts = posts
        }
        .store(in: &cancellables)
    }
}
