//
//  PostCommentsViewModel.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import Combine

class PostCommentsViewModel: ObservableObject {
    var postId: String = ""
    var comments: [String] = []
    private var cancellables: Set<AnyCancellable> = Set()
    private var postsDataController: PostsDataControllerProtocol = PostsDataController()
    
    init() {
        
    }
    
    func fetchComments() {
        postsDataController.getCommentsForPost(postID: self.postId).sink { completion in
            print(completion)
        } receiveValue: { posts in
            print(posts)
        }
        .store(in: &cancellables)
    }
    
}
