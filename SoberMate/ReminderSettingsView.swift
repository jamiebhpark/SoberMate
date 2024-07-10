import SwiftUI
import UserNotifications
import FirebaseAuth

struct ReminderSettingsView: View {
    @State private var reminderMessage: String = ""
    @State private var reminderTime: Date = Date()
    @State private var reminders: [Reminder] = []
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(reminders, id: \.id) { reminder in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(reminder.message)
                                    .font(.headline)
                                Text(reminder.time, style: .time)
                                    .font(.subheadline)
                            }
                            Spacer()
                            Toggle(isOn: .constant(true)) {
                                Text("")
                            }
                            .labelsHidden()
                        }
                    }
                    .onDelete(perform: deleteReminder)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Reminder Settings")
                .navigationBarItems(trailing: EditButton())
                
                VStack(alignment: .leading, spacing: 15) {
                    TextField("Reminder Message", text: $reminderMessage)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    Button(action: {
                        saveReminder()
                    }) {
                        Text("Save Reminder")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.vertical)
                }
                .padding()
            }
            .onAppear(perform: fetchReminders)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveReminder() {
        guard !reminderMessage.isEmpty else {
            alertMessage = "Please enter a reminder message."
            showAlert = true
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "User not authenticated."
            showAlert = true
            return
        }

        let newReminder = Reminder(
            message: reminderMessage,
            time: reminderTime,
            isEnabled: true,
            userId: userId
        )

        FirebaseManager.shared.saveReminder(reminder: newReminder) { result in
            switch result {
            case .success:
                fetchReminders()
                reminderMessage = ""
                reminderTime = Date()
            case .failure(let error):
                alertMessage = "Failed to save reminder: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }

    private func fetchReminders() {
        FirebaseManager.shared.fetchReminders { result in
            switch result {
            case .success(let reminders):
                self.reminders = reminders
            case .failure(let error):
                alertMessage = "Failed to fetch reminders: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }

    private func deleteReminder(at offsets: IndexSet) {
        offsets.map { reminders[$0] }.forEach { reminder in
            FirebaseManager.shared.deleteReminder(reminder: reminder) { result in
                switch result {
                case .success:
                    fetchReminders()
                case .failure(let error):
                    alertMessage = "Failed to delete reminder: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
}
