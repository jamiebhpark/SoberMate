import SwiftUI
import FirebaseAuth

struct CommunityView: View {
    @State private var posts: [Post] = []
    @State private var newPostContent: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(posts, id: \.id) { post in
                        VStack(alignment: .leading) {
                            Text(post.sender)
                                .font(.headline)
                            Text(post.content)
                                .font(.body)
                            Text(post.createdAt, style: .date)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            NavigationLink(destination: PostDetailView(post: post)) {
                                Text("View Comments")
                                    .foregroundColor(.blue)
                            }
                        }
                        .swipeActions {
                            if post.userId == Auth.auth().currentUser?.uid {
                                Button(role: .destructive) {
                                    deletePost(post)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    editPost(post)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                VStack(alignment: .leading, spacing: 15) {
                    TextField("What's on your mind?", text: $newPostContent)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    Button(action: {
                        savePost()
                    }) {
                        Text("Post")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .onAppear(perform: fetchPosts)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func savePost() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "User not authenticated."
            showAlert = true
            return
        }

        let newPost = Post(
            content: newPostContent,
            sender: userId,
            createdAt: Date(),
            userId: userId  // Include the userId here
        )

        FirebaseManager.shared.savePost(post: newPost) { result in
            switch result {
            case .success:
                fetchPosts()
                newPostContent = ""
            case .failure(let error):
                alertMessage = "Failed to save post: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }

    private func fetchPosts() {
        FirebaseManager.shared.fetchPosts { result in
            switch result {
            case .success(let posts):
                self.posts = posts
            case .failure(let error):
                alertMessage = "Failed to fetch posts: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }

    private func deletePost(_ post: Post) {
        FirebaseManager.shared.deletePost(post: post) { result in
            switch result {
            case .success:
                fetchPosts()
            case .failure(let error):
                alertMessage = "Failed to delete post: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }

    private func editPost(_ post: Post) {
        let alert = UIAlertController(title: "Edit Post", message: "Edit your post content", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = post.content
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let textField = alert.textFields?.first, let newContent = textField.text {
                var updatedPost = post
                updatedPost.content = newContent
                FirebaseManager.shared.updatePost(post: updatedPost) { result in
                    switch result {
                    case .success:
                        fetchPosts()
                    case .failure(let error):
                        alertMessage = "Failed to update post: \(error.localizedDescription)"
                        showAlert = true
                    }
                }
            }
        })
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
}
