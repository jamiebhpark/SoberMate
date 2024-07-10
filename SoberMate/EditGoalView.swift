import SwiftUI

struct EditGoalView: View {
    @State var goal: Goal
    var onSave: (Goal) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Name")) {
                    TextField("Enter goal name", text: $goal.goalName)
                }
                Section(header: Text("Goal Reason")) {
                    TextField("Enter goal reason", text: $goal.goalReason)
                }
                Section(header: Text("Daily Limit (Optional)")) {
                    TextField("Daily limit", text: $goal.dailyLimit)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Reward (Optional)")) {
                    TextField("Reward", text: $goal.reward)
                }
                Section(header: Text("Target Date")) {
                    DatePicker("Select target date", selection: $goal.targetDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
            .navigationBarTitle("Edit Goal", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                onSave(goal)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
