import SwiftUI
import FirebaseAuth
import CoreData

struct UserSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showAlert = false
    @State private var showConfirmationAlert = false
    @State private var showResetConfirmationAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    settingsButton(action: { toggleDarkMode() }, title: colorScheme == .dark ? "Switch to Light Mode" : "Switch to Dark Mode", color: .blue)
                    settingsButton(action: { shareApp() }, title: "Share App", color: .orange)
                    settingsButton(action: { showConfirmationAlert = true }, title: "Sign Out", color: .red)
                    settingsButton(action: { showResetConfirmationAlert = true }, title: "Reset Data", color: .purple) // New Reset Button
                }
                .padding()
            }
            .navigationBarTitle("User Settings", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Action Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("Confirm Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Sign Out")) {
                        signOut()
                    },
                    secondaryButton: .cancel()
                )
            }
            /*.alert(isPresented: $showResetConfirmationAlert) {
                Alert(
                    title: Text("Confirm Reset"),
                    message: Text("Are you sure you want to reset all your data? This action cannot be undone."),
                    primaryButton: .destructive(Text("Reset")) {
                        resetData()
                    },
                    secondaryButton: .cancel()
                )
            }*/
        }
    }

    private func settingsButton(action: @escaping () -> Void, title: String, color: Color) -> some View {
        Button(action: action) {
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
        SettingsLogic.toggleDarkMode()
    }

    private func shareApp() {
        SettingsLogic.shareApp()
    }

    private func signOut() {
        print("Sign Out button pressed")
        authViewModel.logOut { result in
            switch result {
            case .success():
                alertMessage = "Successfully signed out."
            case .failure(let error):
                alertMessage = "Error signing out: \(error.localizedDescription)"
            }
            showAlert = true
        }
    }

    /*private func resetData() {
        authViewModel.resetData { result in
            switch result {
            case .success():
                alertMessage = "All data has been successfully reset."
            case .failure(let error):
                alertMessage = "Error resetting data: \(error.localizedDescription)"
            }
            showAlert = true
        }
    }*/
}
