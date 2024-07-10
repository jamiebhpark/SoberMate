import SwiftUI

struct GoalListView: View {
    @State private var goals: [Goal] = []
    @State private var showAlert = false
    @State private var selectedGoal: Goal?
    @State private var isEditing = false
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading goals...")
                } else {
                    List {
                        ForEach(goals, id: \.id) { goal in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(goal.goalName)
                                        .font(.headline)
                                    Text(goal.goalReason)
                                        .font(.subheadline)
                                }
                                Spacer()
                                Button(action: {
                                    self.selectedGoal = goal
                                    self.isEditing = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Button(action: {
                                    self.selectedGoal = goal
                                    self.showAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .onDelete(perform: deleteGoal)
                    }
                }
            }
            .navigationBarTitle("Goals")
            .navigationBarItems(trailing: Button(action: {
                fetchGoals()
            }) {
                Text("Refresh")
            })
            .onAppear {
                fetchGoals()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Goal"),
                    message: Text("Are you sure you want to delete this goal?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let goal = selectedGoal {
                            deleteGoal(goal: goal)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $isEditing, onDismiss: {
                fetchGoals() // Reload goals after editing
            }) {
                if let goal = selectedGoal {
                    EditGoalView(goal: goal) { updatedGoal in
                        updateGoal(updatedGoal)
                        isEditing = false
                    }
                }
            }
        }
    }

    private func fetchGoals() {
        isLoading = true
        FirebaseManager.shared.fetchGoals { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let goals):
                    self.goals = goals
                case .failure(let error):
                    print("Failed to fetch goals: \(error)")
                }
                isLoading = false
            }
        }
    }

    private func deleteGoal(at offsets: IndexSet) {
        offsets.map { goals[$0] }.forEach { goal in
            deleteGoal(goal: goal)
        }
    }

    private func deleteGoal(goal: Goal) {
        FirebaseManager.shared.deleteGoal(goal: goal) { result in
            switch result {
            case .success:
                fetchGoals()
            case .failure(let error):
                print("Failed to delete goal: \(error)")
            }
        }
    }

    private func updateGoal(_ goal: Goal) {
        FirebaseManager.shared.updateGoal(goal: goal) { result in
            switch result {
            case .success:
                fetchGoals()
            case .failure(let error):
                print("Failed to update goal: \(error)")
            }
        }
    }
}
