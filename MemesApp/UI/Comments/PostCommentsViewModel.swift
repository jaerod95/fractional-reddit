//
//  PostCommentsViewModel.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import Combine

class PostCommentsViewModel: ObservableObject {
    var post: PostData?
    @Published var comments: [CommentData] = []
    private var cancellables: Set<AnyCancellable> = Set()
    private var postsDataController: PostsDataControllerProtocol = PostsDataController()
    
    init() {
        
    }
    
    func fetchComments() {
        postsDataController.getCommentsForPost(postID: self.post?.id ?? "").sink { completion in
            print(completion)
        } receiveValue: { comments in
            print(comments)
            self.comments = comments
        }
        .store(in: &cancellables)
    }
    
}
