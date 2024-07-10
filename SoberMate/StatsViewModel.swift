import Foundation
import FirebaseAuth
import Charts

class StatsViewModel: ObservableObject {
    @Published var drinkStats: [DrinkStat] = []
    @Published var feelingStats: [FeelingStat] = []
    
    func fetchStats(for timeFrame: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Drink Stats
        FirebaseManager.shared.fetchDrinkStats(forUser: userId, for: timeFrame) { result in
            switch result {
            case .success(let stats):
                DispatchQueue.main.async {
                    self.drinkStats = self.groupByDetails(stats: stats)
                }
            case .failure(let error):
                print("Failed to fetch drink stats: \(error)")
            }
        }
        
        // Feeling Stats
        FirebaseManager.shared.fetchFeelingStats(forUser: userId, for: timeFrame) { result in
            switch result {
            case .success(let stats):
                DispatchQueue.main.async {
                    self.feelingStats = stats  // 이 부분이 제대로 업데이트 되는지 확인
                }
            case .failure(let error):
                print("Failed to fetch feeling stats: \(error)")
            }
        }
    }
    
    private func groupByDetails(stats: [DrinkStat]) -> [DrinkStat] {
        var groupedStats: [String: Int] = [:]
        
        for stat in stats {
            groupedStats[stat.details, default: 0] += stat.drinks
        }
        
        return groupedStats.map { DrinkStat(date: Date(), drinks: $0.value, details: $0.key, userId: "") }
    }
}
