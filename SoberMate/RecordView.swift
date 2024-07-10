import SwiftUI
import FirebaseAuth

struct RecordView: View {
    @State private var selectedDrink: String = "Beer"
    @State private var amount: String = ""
    @State private var content: String = ""
    @State private var feeling: String = ""
    @State private var location: String = ""
    @State private var showAlert = false
    @State private var isSaving = false

    let drinkOptions = ["Beer", "Whiskey", "Wine", "Vodka", "Soju"]
    let feelings = ["😀", "😐", "😞", "😡"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Drink Details")
                            .font(.headline)
                        Picker("Select Drink", selection: $selectedDrink) {
                            ForEach(drinkOptions, id: \.self) { drink in
                                Text(drink).tag(drink)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        
                        Text("Amount")
                            .font(.headline)
                        TextField("Enter amount", text: $amount)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .keyboardType(.numberPad)
                        
                        Text("Content")
                            .font(.headline)
                        TextField("Enter content", text: $content)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        
                        Text("Feeling")
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
                        
                        Text("Location")
                            .font(.headline)
                        TextField("Enter location", text: $location)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    if isSaving {
                        ProgressView("Saving Record...")
                            .padding()
                    } else {
                        Button(action: {
                            saveRecord()
                        }) {
                            Text("Save Record")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Record Saved"), message: Text("Your drink record has been saved successfully."), dismissButton: .default(Text("OK")))
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarItems(trailing: NavigationLink(destination: RecordListView()) {
                Text("View Records")
            })
        }
    }

    private func saveRecord() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        guard let amountInt = Int(amount) else { return }

        let newRecord = DrinkRecord(
            details: selectedDrink,
            amount: amountInt,
            content: content,
            feeling: feeling,
            location: location,
            date: Date(),
            userId: userID // userId 필드 설정
        )

        isSaving = true

        FirebaseManager.shared.saveDrinkRecord(record: newRecord) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    isSaving = false
                    showAlert = true
                case .failure(let error):
                    print("Failed to save record: \(error)")
                    isSaving = false
                }
            }
        }
    }
}
