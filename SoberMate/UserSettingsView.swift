import SwiftUI
import FirebaseAuth
import Combine

struct UserSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showConfirmationAlert = false
    @State private var showResetConfirmationAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showSetNicknameAlert = false
    @State private var nickname = ""
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    settingsButton(action: toggleDarkMode, title: colorScheme == .dark ? "Switch to Light Mode" : "Switch to Dark Mode", color: .blue)
                    settingsButton(action: shareApp, title: "Share App", color: .orange)
                    settingsButton(action: { showSetNicknameAlert = true }, title: "Set Nickname", color: .green)
                    settingsButton(action: { showDeleteAccountAlert = true }, title: "Delete Account", color: .red)
                }
                .padding()
            }
            .navigationBarTitle("User Settings", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Action Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showConfirmationAlert) {
                Alert(title: Text("Confirm Sign Out"), message: Text("Are you sure you want to sign out?"), primaryButton: .destructive(Text("Sign Out")) {
                    signOut()
                }, secondaryButton: .cancel())
            }
            .alert(isPresented: $showResetConfirmationAlert) {
                Alert(title: Text("Confirm Reset"), message: Text("Are you sure you want to reset all your data? This action cannot be undone."), primaryButton: .destructive(Text("Reset")) {
                    resetData()
                }, secondaryButton: .cancel())
            }
            .alert(isPresented: $showDeleteAccountAlert) {
                Alert(title: Text("Confirm Delete Account"), message: Text("Are you sure you want to delete your account? This action cannot be undone."), primaryButton: .destructive(Text("Delete Account")) {
                    deleteAccount()
                }, secondaryButton: .cancel())
            }
            .alert("Set Nickname", isPresented: $showSetNicknameAlert, actions: {
                TextField("Enter your new nickname", text: $nickname)
                Button("Set") {
                    setNickname(nickname)
                }
                Button("Cancel", role: .cancel) { }
            }, message: {
                Text("Enter your new nickname:")
            })
        
        }
    }

    private func settingsButton(action: @escaping () -> Void, title: String, color: Color) -> some View {
        Button(action: {
            print("\(title) button tapped")
            action()
        }) {
            Text(title)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }

    private func toggleDarkMode() {
        print("Toggle Dark Mode")
        SettingsLogic.toggleDarkMode()
    }

    private func shareApp() {
        print("Share App")
        SettingsLogic.shareApp()
    }

    private func signOut() {
        print("Sign Out function called")
        authViewModel.signOut()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.alertMessage = "Successfully signed out."
                case .failure(let error):
                    self.alertMessage = "Error signing out: \(error.localizedDescription)"
                }
                self.showAlert = true
            }, receiveValue: {})
            .store(in: &cancellables)
    }

    private func resetData() {
        print("Reset Data function called")
        authViewModel.resetData()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.alertMessage = "All data has been successfully reset."
                case .failure(let error):
                    self.alertMessage = "Error resetting data: \(error.localizedDescription)"
                }
                self.showAlert = true
            }, receiveValue: {})
            .store(in: &cancellables)
    }

    private func deleteAccount() {
        print("Delete Account function called")
        authViewModel.deleteUserAccount()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.alertMessage = "Account successfully deleted."
                case .failure(let error):
                    self.alertMessage = "Error deleting account: \(error.localizedDescription)"
                }
                self.showAlert = true
            }, receiveValue: {})
            .store(in: &cancellables)
    }

    private func setNickname(_ nickname: String) {
        print("Set Nickname function called")
        SettingsLogic.setNickname(nickname: nickname)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.alertMessage = "Nickname successfully set."
                case .failure(let error):
                    self.alertMessage = "Error setting nickname: \(error.localizedDescription)"
                }
                self.showAlert = true
            }, receiveValue: {})
            .store(in: &cancellables)
    }
}
