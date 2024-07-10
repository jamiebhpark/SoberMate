import SwiftUI

struct AchievementCardView: View {
    var achievement: Achievement

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundColor(achievement.isUnlocked ? .primary : .gray)
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(achievement.isUnlocked ? .primary : .gray)
                    
                    if !achievement.isUnlocked {
                        ProgressView(value: achievement.progress)
                            .progressViewStyle(LinearProgressViewStyle())
                    }
                    
                    if let unlockDate = achievement.unlockDate {
                        Text("Unlocked on \(unlockDate, formatter: dateFormatter)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                if achievement.isUnlocked {
                    Button(action: {
                        shareAchievement(achievement)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                }
            }
            .padding()
            .background(achievement.isUnlocked ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal)
            .transition(.slide)
            .animation(.spring(), value: achievement.isUnlocked) // 최신 애니메이션 메서드 사용
        }
    }

    private func shareAchievement(_ achievement: Achievement) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        let activityController = UIActivityViewController(activityItems: ["I just unlocked the achievement: \(achievement.title)!"], applicationActivities: nil)
        window.rootViewController?.present(activityController, animated: true, completion: nil)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}
