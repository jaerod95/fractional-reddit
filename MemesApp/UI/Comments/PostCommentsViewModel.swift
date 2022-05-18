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
    var hasMoreComments: Bool = true
    private var isFetching: Bool = false
    private var cancellables: Set<AnyCancellable> = Set()
    private var postsDataController: PostsDataControllerProtocol = PostsDataController()
    
    init() {}
    
    func fetchComments(replacing: Bool = false) {
        if isFetching && !replacing {
            return
        }
        isFetching = true
        var after: String?
        if !replacing {
            if let lastComment = self.comments.last {
                after = lastComment.fullName
            }
        }
        postsDataController.getCommentsForPost(postID: self.post?.id ?? "", after: after).sink { completion in
//            self.isFetching = false
        } receiveValue: { comments in
            if replacing {
                self.comments = comments
            } else {
                self.comments += comments
            }
        }
        .store(in: &cancellables)
    }
    
}
