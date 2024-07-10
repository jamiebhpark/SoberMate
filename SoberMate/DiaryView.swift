import SwiftUI
import FirebaseAuth

struct DiaryView: View {
    @State private var content: String = ""
    @State private var feeling: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false

    let feelings = ["😀", "😐", "😞", "😡"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Date")
                            .font(.headline)
                        DatePicker("Select date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)

                        Text("Your Thoughts")
                            .font(.headline)
                        TextField("Enter your thoughts", text: $content)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        
                        Text("How are you feeling?")
                            .font(.headline)
                        Picker("Select feeling", selection: $feeling) {
                            ForEach(feelings, id: \.self) { feeling in
                                Text(feeling).tag(feeling)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    if isSaving {
                        ProgressView("Saving Diary Entry...")
                            .padding()
                    } else {
                        Button(action: {
                            saveDiaryEntry()
                        }) {
                            Text("Save Diary Entry")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Diary Entry Saved"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Diary", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: DiaryListView()) {
                Text("View Diary Entries")
            })
        }
    }

    private func saveDiaryEntry() {
        guard let userID = Auth.auth().currentUser?.uid else {
            alertMessage = "No user ID found."
            showAlert = true
            return
        }

        let newEntry = DiaryEntry(
            content: content,
            feeling: feeling,
            date: selectedDate,
            userId: userID  // Add this line
        )

        isSaving = true

        FirebaseManager.shared.saveDiaryEntry(entry: newEntry) { result in
            switch result {
            case .success:
                FirebaseManager.shared.saveFeelingStat(from: newEntry) { result in
                    DispatchQueue.main.async {
                        isSaving = false
                        switch result {
                        case .success:
                            alertMessage = "Your diary entry has been saved successfully."
                        case .failure(let error):
                            alertMessage = "Failed to save feeling stat: \(error.localizedDescription)"
                        }
                        showAlert = true
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    alertMessage = "Failed to save diary entry: \(error.localizedDescription)"
                    isSaving = false
                    showAlert = true
                }
            }
        }
    }
}
