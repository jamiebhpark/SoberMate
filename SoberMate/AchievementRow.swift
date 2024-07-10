import SwiftUI

struct AchievementRow: View {
    let achievement: Achievement
    let shareAchievement: (Achievement) -> Void

    var body: some View {
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
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}
