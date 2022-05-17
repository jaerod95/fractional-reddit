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
}

class PostListViewModel: ObservableObject, PostListViewModelProtocol {
    private var cancellables: Set<AnyCancellable> = Set()
    private var postsDataController: PostsDataControllerProtocol = PostsDataController()
    @Published var posts: [PostData] = []
    
    init() {
        postsDataController.getPosts().sink { completion in
            print(completion)
        } receiveValue: { posts in
            print(posts)
            self.posts = posts
        }
        .store(in: &cancellables)

    }
}
