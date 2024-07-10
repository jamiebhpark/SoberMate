import SwiftUI
import FirebaseAuth

struct DiaryListView: View {
    @State private var diaryEntries: [DiaryEntry] = []
    @State private var showAlert = false
    @State private var selectedEntry: DiaryEntry?
    @State private var isEditing = false
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading diary entries...")
                } else {
                    List {
                        ForEach(diaryEntries, id: \.id) { entry in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(entry.content)
                                        .font(.headline)
                                    Text(entry.date, style: .date)
                                        .font(.subheadline)
                                }
                                Spacer()
                                Button(action: {
                                    self.selectedEntry = entry
                                    self.isEditing = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Button(action: {
                                    self.selectedEntry = entry
                                    self.showAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .onDelete(perform: deleteEntry)
                    }
                }
            }
            .navigationBarTitle("Diary Entries")
            .navigationBarItems(trailing: Button(action: {
                fetchDiaryEntries()
            }) {
                Text("Refresh")
            })
            .onAppear {
                fetchDiaryEntries()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Diary Entry"),
                    message: Text("Are you sure you want to delete this entry?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let entry = selectedEntry {
                            deleteEntry(entry: entry)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $isEditing, onDismiss: {
                fetchDiaryEntries() // Reload entries after editing
            }) {
                if let entry = selectedEntry {
                    EditDiaryView(entry: entry) { updatedEntry in
                        updateDiaryEntry(updatedEntry)
                        isEditing = false
                    }
                }
            }
        }
    }

    private func fetchDiaryEntries() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        FirebaseManager.shared.fetchDiaryEntries(forUser: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self.diaryEntries = entries
                case .failure(let error):
                    print("Failed to fetch diary entries: \(error)")
                }
                isLoading = false
            }
        }
    }

    private func deleteEntry(at offsets: IndexSet) {
        offsets.map { diaryEntries[$0] }.forEach { entry in
            deleteEntry(entry: entry)
        }
    }

    private func deleteEntry(entry: DiaryEntry) {
        FirebaseManager.shared.deleteDiaryEntry(entry: entry) { result in
            switch result {
            case .success:
                fetchDiaryEntries()
            case .failure(let error):
                print("Failed to delete diary entry: \(error)")
            }
        }
    }

    private func updateDiaryEntry(_ entry: DiaryEntry) {
        FirebaseManager.shared.updateDiaryEntry(entry: entry) { result in
            switch result {
            case .success:
                fetchDiaryEntries()
            case .failure(let error):
                print("Failed to update diary entry: \(error)")
            }
        }
    }
}
