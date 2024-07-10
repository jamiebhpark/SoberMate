import SwiftUI
import FirebaseAuth

struct RecordListView: View {
    @State private var records: [DrinkRecord] = []
    @State private var showAlert = false
    @State private var selectedRecord: DrinkRecord?
    @State private var isEditing = false
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading records...")
                } else {
                    List {
                        ForEach(records, id: \.id) { record in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(record.details)
                                        .font(.headline)
                                    Text("Amount: \(record.amount)")
                                    Text("Content: \(record.content)")
                                    Text("Feeling: \(record.feeling)")
                                    Text("Location: \(record.location)")
                                }
                                Spacer()
                                Button(action: {
                                    self.selectedRecord = record
                                    self.isEditing = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Button(action: {
                                    self.selectedRecord = record
                                    self.showAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .onDelete(perform: deleteRecord)
                    }
                }
            }
            .navigationBarTitle("Drink Records")
            .navigationBarItems(trailing: Button(action: {
                fetchRecords()
            }) {
                Text("Refresh")
            })
            .onAppear {
                fetchRecords()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Record"),
                    message: Text("Are you sure you want to delete this record?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let record = selectedRecord {
                            deleteRecord(record: record)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $isEditing, onDismiss: {
                fetchRecords() // Reload records after editing
            }) {
                if let record = selectedRecord {
                    EditRecordView(record: record) { updatedRecord in
                        updateRecord(updatedRecord)
                        isEditing = false
                    }
                }
            }
        }
    }

    private func fetchRecords() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        FirebaseManager.shared.fetchDrinkRecords(forUser: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let records):
                    self.records = records
                case .failure(let error):
                    print("Failed to fetch records: \(error)")
                }
                isLoading = false
            }
        }
    }

    private func deleteRecord(at offsets: IndexSet) {
        offsets.map { records[$0] }.forEach { record in
            deleteRecord(record: record)
        }
    }

    private func deleteRecord(record: DrinkRecord) {
        FirebaseManager.shared.deleteDrinkRecord(record: record) { result in
            switch result {
            case .success:
                fetchRecords()
            case .failure(let error):
                print("Failed to delete record: \(error)")
            }
        }
    }

    private func updateRecord(_ record: DrinkRecord) {
        FirebaseManager.shared.updateDrinkRecord(record: record) { result in
            switch result {
            case .success:
                fetchRecords()
            case .failure(let error):
                print("Failed to update record: \(error)")
            }
        }
    }
}
