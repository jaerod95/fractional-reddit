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
    var posts: [RedditLink] { get }
    var hasMorePosts: Bool { get }
    var errorMessages: PassthroughSubject<String, Never> { get }
    func fetchPosts(replacing: Bool)
}

class PostListViewModel: ObservableObject, PostListViewModelProtocol {
    private var cancellables: Set<AnyCancellable> = Set()
    private var postsDataController: RedditAPIDataControllerProtocol = RedditAPIDataController()
    private var isFetching: Bool = false
    @Published var errorMessages: PassthroughSubject<String, Never> = PassthroughSubject()
    @Published var posts: [RedditLink] = []
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
        postsDataController.getLinks(after: after).sink { completion in
            self.isFetching = false
            switch completion {
            case .failure:
                self.errorMessages.send("Unable to grab comments, try again")
            default:
                break
            }
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
