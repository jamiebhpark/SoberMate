import SwiftUI
import FirebaseAuth

struct AchievementsView: View {
    @State private var achievements: [Achievement] = []
    @State private var daysSober: Int = 0
    @State private var hasFetchedAchievements = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if achievements.isEmpty {
                        Text("No achievements yet.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("Sober for \(daysSober) days!")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 20)

                        ForEach(achievements) { achievement in
                            AchievementCardView(achievement: achievement)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Achievements", displayMode: .inline)
            .onAppear {
                if !hasFetchedAchievements {
                    fetchAchievements()
                    hasFetchedAchievements = true
                }
            }
        }
    }

    private func fetchAchievements() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found")
            return
        }
        
        AchievementsManager.shared.fetchAchievements(forUser: userId) { result in
            switch result {
            case .success(let (days, achievements)):
                self.daysSober = days
                self.achievements = achievements
            case .failure(let error):
                print("Failed to fetch achievements: \(error)")
            }
        }
    }
}
