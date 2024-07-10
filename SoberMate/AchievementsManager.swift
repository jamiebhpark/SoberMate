import Foundation
import FirebaseFirestore

class AchievementsManager {
    static let shared = AchievementsManager()
    private let db = Firestore.firestore()

    private init() {}

    func fetchAchievements(forUser userId: String, completion: @escaping (Result<(Int, [Achievement]), Error>) -> Void) {
        FirebaseManager.shared.fetchUserStartDate { result in
            switch result {
            case .success(let startDate):
                let days = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
                print("Days sober: \(days)")
                let achievements = self.generateAchievements(for: days)
                FirebaseManager.shared.fetchAchievements(forUser: userId) { fetchResult in
                    switch fetchResult {
                    case .success(let fetchedAchievements):
                        var updatedAchievements = achievements
                        for achievement in fetchedAchievements {
                            if let index = updatedAchievements.firstIndex(where: { $0.id == achievement.id }) {
                                updatedAchievements[index] = achievement
                            } else {
                                updatedAchievements.append(achievement)
                            }
                        }
                        completion(.success((days, updatedAchievements)))
                    case .failure(let error):
                        print("Failed to fetch achievements: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("Failed to fetch start date: \(error)")
                completion(.failure(error))
            }
        }
    }

    private func generateAchievements(for daysSober: Int) -> [Achievement] {
        var achievementsSet = Set<Achievement>()

        let firstDayAchievement = Achievement(
            id: UUID().uuidString,
            title: "First Sober Day",
            description: "Complete your first day without alcohol.",
            isUnlocked: daysSober >= 1,
            progress: min(Double(daysSober) / 1.0, 1.0),
            unlockDate: daysSober >= 1 ? Date() : nil
        )
        achievementsSet.insert(firstDayAchievement)
        
        let thirdDayAchievement = Achievement(
            id: UUID().uuidString,
            title: "Third Sober Day",
            description: "Complete your third day without alcohol.",
            isUnlocked: daysSober >= 3,
            progress: min(Double(daysSober) / 3.0, 1.0),
            unlockDate: daysSober >= 3 ? Date() : nil
        )
        achievementsSet.insert(thirdDayAchievement)
        
        let firstWeekAchievement = Achievement(
            id: UUID().uuidString,
            title: "First Sober Week",
            description: "Complete your first week without alcohol.",
            isUnlocked: daysSober >= 7,
            progress: min(Double(daysSober) / 7.0, 1.0),
            unlockDate: daysSober >= 7 ? Date() : nil
        )
        achievementsSet.insert(firstWeekAchievement)
        
        let secondWeekAchievement = Achievement(
            id: UUID().uuidString,
            title: "Second Sober Week",
            description: "Complete your second week without alcohol.",
            isUnlocked: daysSober >= 14,
            progress: min(Double(daysSober) / 14.0, 1.0),
            unlockDate: daysSober >= 14 ? Date() : nil
        )
        achievementsSet.insert(secondWeekAchievement)
        
        let firstMonthAchievement = Achievement(
            id: UUID().uuidString,
            title: "First Sober Month",
            description: "Complete your first month without alcohol.",
            isUnlocked: daysSober >= 30,
            progress: min(Double(daysSober) / 30.0, 1.0),
            unlockDate: daysSober >= 30 ? Date() : nil
        )
        achievementsSet.insert(firstMonthAchievement)
        
        let thirdMonthAchievement = Achievement(
            id: UUID().uuidString,
            title: "Third Sober Month",
            description: "Complete your third month without alcohol.",
            isUnlocked: daysSober >= 90,
            progress: min(Double(daysSober) / 90.0, 1.0),
            unlockDate: daysSober >= 90 ? Date() : nil
        )
        achievementsSet.insert(thirdMonthAchievement)
        
        let firstYearAchievement = Achievement(
            id: UUID().uuidString,
            title: "First Sober Year",
            description: "Complete your first year without alcohol.",
            isUnlocked: daysSober >= 365,
            progress: min(Double(daysSober) / 365.0, 1.0),
            unlockDate: daysSober >= 365 ? Date() : nil
        )
        achievementsSet.insert(firstYearAchievement)

        let achievementsArray = Array(achievementsSet).sorted { getAchievementOrder($0.title) < getAchievementOrder($1.title) }
        print("Generated achievements: \(achievementsArray)")
        return achievementsArray
    }

    private func getAchievementOrder(_ title: String) -> Int {
        let order = [
            "First Sober Day": 1,
            "Third Sober Day": 2,
            "First Sober Week": 3,
            "Second Sober Week": 4,
            "First Sober Month": 5,
            "Third Sober Month": 6,
            "First Sober Year": 7
        ]
        return order[title] ?? 100 // Default to a large number if title not found
    }
}
