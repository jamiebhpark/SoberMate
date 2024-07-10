import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(features) { feature in
                        NavigationLink(destination: feature.destination) {
                            featureButton(title: feature.title, iconName: feature.iconName, color: feature.color)
                        }
                    }
                }
                .padding()
                .navigationBarTitle("SoberMate", displayMode: .inline)
                .navigationBarItems(leading: leadingBarItem, trailing: trailingBarItem)
            }
        }
    }

    @ViewBuilder
    private func featureButton(title: String, iconName: String, color: Color) -> some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
            Text(title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
        }
        .padding()
        .background(color)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    private var leadingBarItem: some View {
        NavigationLink(destination: ReminderSettingsView()) {
            Image(systemName: "bell")
                .imageScale(.large)
                .padding()
        }
    }

    private var trailingBarItem: some View {
        NavigationLink(destination: UserSettingsView()) {
            Image(systemName: "gear")
                .imageScale(.large)
                .padding()
        }
    }

    private var features: [Feature] {
        [
            Feature(title: "Set Goals", destination: GoalView(), iconName: "target", color: .blue),
            Feature(title: "Record Drinks", destination: RecordView(), iconName: "pencil", color: .green),
            Feature(title: "Diary", destination: DiaryView(), iconName: "book", color: .purple),
            Feature(title: "Community", destination: CommunityView(), iconName: "person.2", color: .orange),
            Feature(title: "Statistics", destination: StatsView(), iconName: "chart.bar", color: .red),
            Feature(title: "Achievements", destination: AchievementsView(), iconName: "star", color: .yellow),
            Feature(title: "Emergency Contacts", destination: EmergencyView(), iconName: "phone", color: .pink)
        ]
    }
}

struct Feature: Identifiable {
    let id = UUID()
    let title: String
    let destination: AnyView
    let iconName: String
    let color: Color
}

extension Feature {
    init<Destination: View>(title: String, destination: Destination, iconName: String, color: Color) {
        self.title = title
        self.destination = AnyView(destination)
        self.iconName = iconName
        self.color = color
    }
}
