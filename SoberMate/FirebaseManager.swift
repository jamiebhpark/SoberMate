import Foundation
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import UserNotifications
import Combine

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    private init() {}
    
    let db = Firestore.firestore()
    // MARK: - SignIn&UP Methods
    // 회원가입
    func signUp(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                completion(.failure(NSError(domain: "No user found", code: 0, userInfo: nil)))
                return
            }
            
            let newUser = User(username: username, email: email)
            
            do {
                try self.db.collection("users").document(user.uid).setData(from: newUser) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // 로그인
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
    
    // MARK: - Goal Methods
    func saveGoal(goal: Goal, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        
        var goalWithUserId = goal
        goalWithUserId.userId = userID
        
        do {
            let _ = try db.collection("users").document(userID).collection("goals").addDocument(from: goalWithUserId) { error in
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            print("Caught error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func fetchGoals(completion: @escaping (Result<[Goal], Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        
        db.collection("users").document(userID).collection("goals").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    let goals = snapshot.documents.compactMap { doc -> Goal? in
                        return try? doc.data(as: Goal.self)
                    }
                    completion(.success(goals))
                } else {
                    completion(.success([]))
                }
            }
        }
    }
    
    func deleteGoal(goal: Goal, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid, let documentId = goal.id else {
            completion(.failure(NSError(domain: "Invalid Goal ID", code: 0, userInfo: nil)))
            return
        }
        db.collection("users").document(userID).collection("goals").document(documentId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateGoal(goal: Goal, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid, let documentId = goal.id else {
            completion(.failure(NSError(domain: "Invalid Goal ID", code: 0, userInfo: nil)))
            return
        }
        do {
            try db.collection("users").document(userID).collection("goals").document(documentId).setData(from: goal) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchUserStartDate(completion: @escaping (Result<Date, Error>) -> Void) {
        fetchGoals { result in
            switch result {
            case .success(let goals):
                if let startDate = goals.first?.startDate {
                    print("Fetched start date: \(startDate)")
                    completion(.success(startDate))
                } else {
                    print("No start date found")
                    completion(.failure(NSError(domain: "No start date found", code: 0, userInfo: nil)))
                }
            case .failure(let error):
                print("Failed to fetch goals: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - DrinkRecord Methods
    func saveDrinkRecord(record: DrinkRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        
        var recordWithUserId = record
        recordWithUserId.userId = userID
        
        do {
            let _ = try db.collection("drinkRecords").addDocument(from: recordWithUserId) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchDrinkRecords(forUser userId: String, completion: @escaping (Result<[DrinkRecord], Error>) -> Void) {
        db.collection("drinkRecords").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    let records = snapshot.documents.compactMap { doc -> DrinkRecord? in
                        return try? doc.data(as: DrinkRecord.self)
                    }
                    completion(.success(records))
                } else {
                    completion(.success([]))
                }
            }
        }
    }
    
    func deleteDrinkRecord(record: DrinkRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentId = record.id else {
            completion(.failure(NSError(domain: "Invalid Record ID", code: 0, userInfo: nil)))
            return
        }
        db.collection("drinkRecords").document(documentId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateDrinkRecord(record: DrinkRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentId = record.id else {
            completion(.failure(NSError(domain: "Invalid Record ID", code: 0, userInfo: nil)))
            return
        }
        do {
            try db.collection("drinkRecords").document(documentId).setData(from: record) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    
    // MARK: - DiaryEntry Methods
    func saveDiaryEntry(entry: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        
        var entryWithUserId = entry
        entryWithUserId.userId = userID
        
        do {
            let _ = try db.collection("diaryEntries").addDocument(from: entryWithUserId) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchDiaryEntries(forUser userId: String, completion: @escaping (Result<[DiaryEntry], Error>) -> Void) {
        db.collection("diaryEntries").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    let entries = snapshot.documents.compactMap { doc -> DiaryEntry? in
                        return try? doc.data(as: DiaryEntry.self)
                    }
                    completion(.success(entries))
                } else {
                    completion(.success([]))
                }
            }
        }
    }
    
    func deleteDiaryEntry(entry: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid, let documentId = entry.id else {
            completion(.failure(NSError(domain: "Invalid Entry ID", code: 0, userInfo: nil)))
            return
        }
        db.collection("diaryEntries").document(documentId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateDiaryEntry(entry: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid, let documentId = entry.id else {
            completion(.failure(NSError(domain: "Invalid Entry ID", code: 0, userInfo: nil)))
            return
        }
        do {
            try db.collection("diaryEntries").document(documentId).setData(from: entry) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    
    // MARK: - CommunityMessage Methods
    
    func saveCommunityMessage(message: CommunityMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        var newMessage = message
        newMessage.userId = userId
        do {
            let _ = try db.collection("communityMessages").addDocument(from: newMessage) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchCommunityMessages(completion: @escaping (Result<[CommunityMessage], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        db.collection("communityMessages").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    let messages = snapshot.documents.compactMap { doc -> CommunityMessage? in
                        return try? doc.data(as: CommunityMessage.self)
                    }
                    completion(.success(messages))
                } else {
                    completion(.success([]))
                }
            }
        }
    }
    
    // MARK: - Post Methods
    
    func savePost(post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        
        var newPost = post
        newPost.userId = userId
        
        do {
            let _ = try db.collection("posts").addDocument(from: newPost) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        db.collection("posts").order(by: "createdAt", descending: true).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    let posts = snapshot.documents.compactMap { doc -> Post? in
                        return try? doc.data(as: Post.self)
                    }
                    completion(.success(posts))
                } else {
                    completion(.success([]))
                }
            }
        }
    }
    
    func updatePost(post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentId = post.id else {
            completion(.failure(NSError(domain: "Invalid Post ID", code: 0, userInfo: nil)))
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, post.userId == userId else {
            completion(.failure(NSError(domain: "Unauthorized", code: 0, userInfo: nil)))
            return
        }
        
        do {
            try db.collection("posts").document(documentId).setData(from: post) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func deletePost(post: Post, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentId = post.id else {
            completion(.failure(NSError(domain: "Invalid Post ID", code: 0, userInfo: nil)))
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, post.userId == userId else {
            completion(.failure(NSError(domain: "Unauthorized", code: 0, userInfo: nil)))
            return
        }
        
        db.collection("posts").document(documentId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Comment Methods
    
    func saveComment(postId: String, comment: Comment, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        
        var newComment = comment
        newComment.userId = userId
        
        do {
            let _ = try db.collection("posts").document(postId).collection("comments").addDocument(from: newComment) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func fetchComments(postId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        db.collection("posts").document(postId).collection("comments").order(by: "createdAt", descending: true).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    let comments = snapshot.documents.compactMap { doc -> Comment? in
                        return try? doc.data(as: Comment.self)
                    }
                    completion(.success(comments))
                } else {
                    completion(.success([]))
                }
            }
        }
    }

    func updateComment(postId: String, comment: Comment, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentId = comment.id else {
            completion(.failure(NSError(domain: "Invalid Comment ID", code: 0, userInfo: nil)))
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, comment.userId == userId else {
            completion(.failure(NSError(domain: "Unauthorized", code: 0, userInfo: nil)))
            return
        }
        
        do {
            try db.collection("posts").document(postId).collection("comments").document(documentId).setData(from: comment) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    func deleteComment(postId: String, comment: Comment, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentId = comment.id else {
            completion(.failure(NSError(domain: "Invalid Comment ID", code: 0, userInfo: nil)))
            return
        }
        guard let userId = Auth.auth().currentUser?.uid, comment.userId == userId else {
            completion(.failure(NSError(domain: "Unauthorized", code: 0, userInfo: nil)))
            return
        }
        
        db.collection("posts").document(postId).collection("comments").document(documentId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Reminder Methods
    func saveReminder(reminder: Reminder, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        var newReminder = reminder
        newReminder.userId = userId
        
        do {
            let _ = try db.collection("reminders").addDocument(from: newReminder) { [weak self] error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // 로컬 알림 스케줄링
                    self?.scheduleLocalNotification(for: newReminder)
                    
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchReminders(completion: @escaping (Result<[Reminder], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        
        db.collection("reminders").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    let reminders = snapshot.documents.compactMap { doc -> Reminder? in
                        return try? doc.data(as: Reminder.self)
                    }
                    completion(.success(reminders))
                } else {
                    completion(.success([]))
                }
            }
        }
    }
    
    func deleteReminder(reminder: Reminder, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentId = reminder.id else {
            completion(.failure(NSError(domain: "Invalid Reminder ID", code: 0, userInfo: nil)))
            return
        }
        db.collection("reminders").document(documentId).delete { [weak self] error in
            if let error = error {
                completion(.failure(error))
            } else {
                // 로컬 알림 제거
                self?.removeLocalNotification(for: reminder)
                
                completion(.success(()))
            }
        }
    }
    
    // 로컬 알림 스케줄링 함수
    func scheduleLocalNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = reminder.message
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: reminder.id ?? UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local notification: \(error.localizedDescription)")
            }
        }
    }
    
    // 로컬 알림 제거 함수
    func removeLocalNotification(for reminder: Reminder) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id ?? ""])
    }
    
    // MARK: - Stats Methods
    func fetchDrinkStats(forUser userId: String, for timeFrame: String, completion: @escaping (Result<[DrinkStat], Error>) -> Void) {
        db.collection("drinkRecords").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            let stats: [DrinkStat] = documents.compactMap { doc in
                let data = doc.data()
                guard let timestamp = data["date"] as? Timestamp,
                      let drinks = data["amount"] as? Int,
                      let details = data["details"] as? String else {
                    return nil
                }
                return DrinkStat(date: timestamp.dateValue(), drinks: drinks, details: details, userId: userId)
            }
            completion(.success(stats))
        }
    }
    
    func fetchFeelingStats(forUser userId: String, for timeFrame: String, completion: @escaping (Result<[FeelingStat], Error>) -> Void) {
        db.collection("feelingStats").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            let stats: [FeelingStat] = documents.compactMap { doc in
                let data = doc.data()
                guard let timestamp = data["date"] as? Timestamp,
                      let feeling = data["feeling"] as? Int else {
                    return nil
                }
                return FeelingStat(date: timestamp.dateValue(), feeling: feeling, userId: userId)
            }
            completion(.success(stats))
        }
    }
    
    func saveFeelingStat(from entry: DiaryEntry, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        
        let feelingValue: Int
        switch entry.feeling {
        case "😀": feelingValue = 4
        case "😐": feelingValue = 3
        case "😞": feelingValue = 2
        case "😡": feelingValue = 1
        default: feelingValue = 0
        }
        
        let feelingStat = FeelingStat(date: entry.date, feeling: feelingValue, userId: userId)
        
        do {
            _ = try db.collection("feelingStats").addDocument(from: feelingStat)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteFeelingStat(for date: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }
        
        let query = db.collection("feelingStats").whereField("userId", isEqualTo: userId).whereField("date", isEqualTo: date)
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let documents = snapshot?.documents else {
                    completion(.failure(NSError(domain: "No documents found", code: 0, userInfo: nil)))
                    return
                }
                
                for document in documents {
                    document.reference.delete { error in
                        if let error = error {
                            completion(.failure(error))
                        }
                    }
                }
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Achievement Methods
    func saveAchievement(_ achievement: Achievement, forUser userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let _ = try db.collection("users").document(userId).collection("achievements").addDocument(from: achievement) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchAchievements(forUser userId: String, completion: @escaping (Result<[Achievement], Error>) -> Void) {
        db.collection("users").document(userId).collection("achievements").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let snapshot = snapshot {
                    let achievements = snapshot.documents.compactMap { doc -> Achievement? in
                        return try? doc.data(as: Achievement.self)
                    }
                    completion(.success(achievements))
                } else {
                    completion(.success([]))
                }
            }
        }
    }
    
    func deleteAchievement(_ achievement: Achievement, forUser userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentId = achievement.id else {
            completion(.failure(NSError(domain: "Invalid Achievement ID", code: 0, userInfo: nil)))
            return
        }
        db.collection("users").document(userId).collection("achievements").document(documentId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateAchievement(_ achievement: Achievement, forUser userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let documentId = achievement.id else {
            completion(.failure(NSError(domain: "Invalid Achievement ID", code: 0, userInfo: nil)))
            return
        }
        do {
            try db.collection("users").document(userId).collection("achievements").document(documentId).setData(from: achievement) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    // MARK: - Reset Logic
// 로그아웃
func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
    do {
        try Auth.auth().signOut()
        completion(.success(()))
    } catch let signOutError as NSError {
        completion(.failure(signOutError))
    }
}
    
    // MARK: - Reset Logic
    func resetUserData(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found")
            completion(.failure(NSError(domain: "No user ID found", code: 0, userInfo: nil)))
            return
        }

        let collections = [
            "goals",
            "drinkRecords",
            "diaryEntries",
            "communityMessages",
            "reminders",
            "achievements",
            "feelingStats",
            "posts"
        ]

        let userDocument = db.collection("users").document(userId)
        let topLevelCollections = ["drinkRecords", "feelingStats", "diaryEntries", "posts"]

        let group = DispatchGroup()
        var firstError: Error?

        // Delete user-specific subcollections
        for collection in collections {
            group.enter()
            userDocument.collection(collection).getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting documents for collection \(collection): \(error.localizedDescription)")
                    firstError = error
                    group.leave()
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents found for collection \(collection)")
                    group.leave()
                    return
                }

                let batch = self.db.batch()
                for document in documents {
                    batch.deleteDocument(document.reference)
                }
                batch.commit { batchError in
                    if let batchError = batchError {
                        print("Error committing batch delete for collection \(collection): \(batchError.localizedDescription)")
                        firstError = batchError
                    }
                    group.leave()
                }
            }
        }

        // Delete top-level collections where userId is a field
        for collection in topLevelCollections {
            group.enter()
            db.collection(collection).whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting top-level documents for collection \(collection): \(error.localizedDescription)")
                    firstError = error
                    group.leave()
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No top-level documents found for collection \(collection)")
                    group.leave()
                    return
                }

                let batch = self.db.batch()
                for document in documents {
                    // Delete comments subcollection if exists
                    if collection == "posts" {
                        self.deleteSubcollection(postId: document.documentID, subcollection: "comments", group: group)
                    }
                    batch.deleteDocument(document.reference)
                }
                batch.commit { batchError in
                    if let batchError = batchError {
                        print("Error committing batch delete for top-level collection \(collection): \(batchError.localizedDescription)")
                        firstError = batchError
                    }
                    group.leave()
                }
            }
        }

        // Delete user document itself
        group.enter()
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user document: \(error.localizedDescription)")
                firstError = error
            }
            group.leave()
        }

        group.notify(queue: .main) {
            if let error = firstError {
                print("Reset user data failed: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("All user data successfully reset")
                completion(.success(()))
            }
        }
    }

    // Helper function to delete subcollections
    private func deleteSubcollection(postId: String, subcollection: String, group: DispatchGroup) {
        group.enter()
        db.collection("posts").document(postId).collection(subcollection).getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents for subcollection \(subcollection): \(error.localizedDescription)")
                group.leave()
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found for subcollection \(subcollection)")
                group.leave()
                return
            }

            let batch = self.db.batch()
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            batch.commit { batchError in
                if let batchError = batchError {
                    print("Error committing batch delete for subcollection \(subcollection): \(batchError.localizedDescription)")
                }
                group.leave()
            }
        }
    }

    // MARK : Nickname Logic
    func setNickname(nickname: String) -> AnyPublisher<Void, Error> {
        guard let user = Auth.auth().currentUser else {
            return Fail(error: NSError(domain: "No user signed in", code: 0, userInfo: nil))
                .eraseToAnyPublisher()
        }

        return Future<Void, Error> { promise in
            self.db.collection("users").document(user.uid).setData(["nickname": nickname], merge: true) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = nickname
                    changeRequest.commitChanges { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func getNickname(userId: String) -> AnyPublisher<String, Error> {
        return Future<String, Error> { promise in
            self.db.collection("users").document(userId).getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    let nickname = data?["nickname"] as? String ?? "Anonymous"
                    promise(.success(nickname))
                } else {
                    promise(.failure(error ?? NSError(domain: "Document does not exist", code: 0, userInfo: nil)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
