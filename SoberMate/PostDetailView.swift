import SwiftUI
import FirebaseAuth

struct PostDetailView: View {
    var post: Post
    @State private var commentContent: String = ""
    @State private var comments: [Comment] = []

    var body: some View {
        VStack {
            List {
                ForEach(comments, id: \.id) { comment in
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(comment.sender)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Text(comment.content)
                            }
                            Spacer()
                            Text(comment.createdAt, style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.vertical, 5)
                    .swipeActions {
                        if comment.userId == Auth.auth().currentUser?.uid {
                            Button(action: {
                                editComment(comment: comment)
                            }) {
                                Text("Edit")
                            }
                            .tint(.orange)

                            Button(action: {
                                deleteComment(comment: comment)
                            }) {
                                Text("Delete")
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .onAppear {
                fetchComments()
            }

            HStack {
                TextField("Enter comment", text: $commentContent)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    sendComment()
                }) {
                    Text("Comment")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationBarTitle("Comments", displayMode: .inline)
    }

    private func sendComment() {
        guard let userId = Auth.auth().currentUser?.uid, let postId = post.id else { return }
        
        let newComment = Comment(
            content: commentContent,
            sender: Auth.auth().currentUser?.displayName ?? "Anonymous",
            createdAt: Date(),
            userId: userId
        )

        FirebaseManager.shared.saveComment(postId: postId, comment: newComment) { result in
            switch result {
            case .success:
                fetchComments()
                commentContent = ""
            case .failure(let error):
                print("Failed to save comment: \(error)")
            }
        }
    }

    private func fetchComments() {
        guard let postId = post.id else { return }
        
        FirebaseManager.shared.fetchComments(postId: postId) { result in
            switch result {
            case .success(let comments):
                self.comments = comments
            case .failure(let error):
                print("Failed to fetch comments: \(error)")
            }
        }
    }

    private func editComment(comment: Comment) {
        let alert = UIAlertController(title: "Edit Comment", message: "Edit your comment content", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = comment.content
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let textField = alert.textFields?.first, let newContent = textField.text {
                var updatedComment = comment
                updatedComment.content = newContent
                FirebaseManager.shared.updateComment(postId: post.id!, comment: updatedComment) { result in
                    switch result {
                    case .success:
                        fetchComments()
                    case .failure(let error):
                        print("Failed to update comment: \(error)")
                    }
                }
            }
        })
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }

    private func deleteComment(comment: Comment) {
        guard let postId = post.id else { return }
        FirebaseManager.shared.deleteComment(postId: postId, comment: comment) { result in
            switch result {
            case .success:
                fetchComments()
            case .failure(let error):
                print("Failed to delete comment: \(error)")
            }
        }
    }
}
