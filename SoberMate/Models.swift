import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String? = nil
    var username: String
    var email: String
    //var userId: String // Add this line
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
       //case userId // Add this line
    }
}

struct Goal: Identifiable, Codable {
    @DocumentID var id: String? = nil  // nil로 초기화하여 Firestore가 ID를 자동으로 생성하도록 합니다.
    var userId: String  // 사용자 ID 추가
    var goalName: String
    var goalReason: String
    var dailyLimit: String
    var reward: String
    var targetDate: Date
    var startDate: Date  // 금주 시작 날짜 추가
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId  // 추가
        case goalName
        case goalReason
        case dailyLimit
        case reward
        case targetDate
        case startDate
    }
}

struct DrinkRecord: Identifiable, Codable {
    @DocumentID var id: String? = nil  // nil로 초기화하여 Firestore가 ID를 자동으로 생성하도록 합니다.
    var details: String
    var amount: Int
    var content: String
    var feeling: String
    var location: String
    var date: Date
    var userId: String // userId 필드 추가
    
    enum CodingKeys: String, CodingKey {
        case id
        case details
        case amount
        case content
        case feeling
        case location
        case date
        case userId // userId 필드 추가
    }
}

struct DiaryEntry: Identifiable, Codable {
    @DocumentID var id: String? = nil
    var content: String
    var feeling: String
    var date: Date
    var userId: String  // Add this line
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case feeling
        case date
        case userId  // Add this line
    }
}

struct CommunityMessage: Identifiable, Codable {
    @DocumentID var id: String? = nil  // nil로 초기화하여 Firestore가 ID를 자동으로 생성하도록 합니다.
    var content: String
    var sender: String
    var createdAt: Date
    var userId: String  // Add this line

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case sender
        case createdAt
        case userId  // Add this line
    }
}

struct Reminder: Identifiable, Codable {
    @DocumentID var id: String? = nil
    var message: String
    var time: Date
    var isEnabled: Bool
    var userId: String  // Add this line

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case time
        case isEnabled
        case userId  // Add this line
    }
}

struct DrinkStat: Identifiable, Codable {
    @DocumentID var id: String? = nil
    var date: Date
    var drinks: Int
    var details: String  // 'Drink Details' 필드 추가
    var userId: String  // Add this line

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case drinks
        case details  // 'Drink Details' 필드 추가
        case userId  // Add this line
    }
}

struct FeelingStat: Identifiable, Codable {
    @DocumentID var id: String? = nil
    var date: Date
    var feeling: Int
    var userId: String  // Add this line

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case feeling
        case userId  // Add this line
    }
}


struct Post: Identifiable, Codable {
    @DocumentID var id: String? = nil
    var content: String
    var sender: String
    var createdAt: Date
    var userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case sender
        case createdAt
        case userId
    }
}


struct Comment: Identifiable, Codable {
    @DocumentID var id: String? = nil
    var content: String
    var sender: String
    var createdAt: Date
    var userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case sender
        case createdAt
        case userId
    }
}



struct Achievement: Identifiable, Codable, Hashable {
    @DocumentID var id: String? = UUID().uuidString  // Firestore document ID
    var userId: String?  // User ID for user-specific achievements
    var title: String
    var description: String
    var isUnlocked: Bool
    var progress: Double
    var unlockDate: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId  // Include userId in the coding keys
        case title
        case description
        case isUnlocked
        case progress
        case unlockDate
    }
}

