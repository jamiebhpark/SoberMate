import SwiftUI
import FirebaseAuth

struct GoalView: View {
    @State private var goalName: String = ""
    @State private var goalReason: String = ""
    @State private var dailyLimit: String = ""
    @State private var reward: String = ""
    @State private var targetDate: Date = Date()
    @State private var startDate: Date = Date() // 금주 시작 날짜를 추가
    @State private var showAlert = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Goal Name")
                            .font(.headline)
                        TextField("Enter goal name", text: $goalName)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        
                        Text("Goal Reason")
                            .font(.headline)
                        TextField("Enter goal reason", text: $goalReason)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        
                        Text("Daily Limit (Optional)")
                            .font(.headline)
                        TextField("Daily limit", text: $dailyLimit)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .keyboardType(.numberPad)
                        
                        Text("Reward (Optional)")
                            .font(.headline)
                        TextField("Reward", text: $reward)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        
                        Text("Target Date")
                            .font(.headline)
                        DatePicker("Select target date", selection: $targetDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        
                        Text("Start Date")
                            .font(.headline)
                        DatePicker("Select start date", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    if isSaving {
                        ProgressView("Saving Goal...")
                            .padding()
                    } else {
                        Button(action: {
                            saveGoal()
                        }) {
                            Text("Save Goal")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Goal Saved"), message: Text("Your goal has been saved successfully."), dismissButton: .default(Text("OK")))
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Set Goals", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: GoalListView()) {
                Text("View Goals")
            })
        }
    }
    
    private func saveGoal() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user ID found")
            return
        }

        let newGoal = Goal(
            userId: userID,  // 사용자 ID 설정
            goalName: goalName,
            goalReason: goalReason,
            dailyLimit: dailyLimit,
            reward: reward,
            targetDate: targetDate,
            startDate: startDate // 금주 시작 날짜 추가
        )
        
        isSaving = true
        
        FirebaseManager.shared.saveGoal(goal: newGoal) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    isSaving = false
                    showAlert = true
                case .failure(let error):
                    print("Failed to save goal: \(error.localizedDescription)")
                    isSaving = false
                    // 추가적인 오류 확인 로그
                    if let nsError = error as NSError? {
                        print("Error domain: \(nsError.domain)")
                        print("Error code: \(nsError.code)")
                        print("Error userInfo: \(nsError.userInfo)")
                    }
                }
            }
        }
    }
}
