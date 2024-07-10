import SwiftUI
import FirebaseAuth

struct EmailLoginView: View {
    @Binding var isSignedIn: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var isSignUp = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Text(isSignUp ? "Sign Up" : "Sign In")
                .font(.largeTitle)
                .padding(.bottom, 40)

            if isSignUp {
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
            }

            TextField("Email", text: $email)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)

            Button(action: {
                isSignUp ? signUp() : signIn()
            }) {
                Text(isSignUp ? "Sign Up" : "Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSignUp ? Color.green : Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            Button(action: {
                isSignUp.toggle()
            }) {
                Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            isSignedIn = true
        }
    }

    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }

            guard let user = authResult?.user else {
                alertMessage = "User not found"
                showAlert = true
                return
            }

            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges { error in
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }
                isSignedIn = true
            }
        }
    }
}
