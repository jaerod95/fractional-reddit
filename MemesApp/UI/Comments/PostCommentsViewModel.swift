//
//  PostCommentsViewModel.swift
//  MemesApp
//
//  Created by Jason Rodriguez on 5/17/22.
//

import Foundation
import Combine

protocol PostCommentsViewModelProtocol: ObservableObject {
    var comments: [CommentData] { get }
    var post: PostData? { get }
    var errorMessages: PassthroughSubject<String, Never> { get }
    var hasMoreComments: Bool { get }
    func fetchComments(replacing: Bool)
}

class PostCommentsViewModel: PostCommentsViewModelProtocol {
    @Published var comments: [CommentData] = []
    @Published var errorMessages: PassthroughSubject<String, Never> = PassthroughSubject()
    /// Selected Post
    var post: PostData?
    /// Whether more comments can be fetched
    var hasMoreComments: Bool = true
    /// True if we are making a network call
    private var isFetching: Bool = false
    /// Store Combine cancellables
    private var cancellables: Set<AnyCancellable> = Set()
    /// Data Controller for API access
    private var postsDataController: RedditDataControllerProtocol = RedditDataController()
    
    init() {}
    
    /// Fetches more Comments from the API
    /// - Parameter replacing: Whether to replace existing comments with new comments
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
            switch completion {
            case .failure:
                self.errorMessages.send("Unable to grab comments, try again")
            default:
                break
            }
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
