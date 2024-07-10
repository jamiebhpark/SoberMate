import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices

class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = Auth.auth().currentUser != nil

    func handleAuthorization(_ authResults: ASAuthorization) {
        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
            guard let identityToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }

            guard let tokenString = String(data: identityToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(identityToken.debugDescription)")
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nil)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Error authenticating with Apple: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    self.isSignedIn = true
                }
            }
        }
    }

    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("No client ID found in Firebase options")
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("There is no root view controller")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("Error signing in with Google: \(error.localizedDescription)")
                return
            }

            guard let user = signInResult?.user else {
                print("Error with Google authentication")
                return
            }

            guard let idToken = user.idToken?.tokenString else {
                print("Error retrieving idToken")
                return
            }

            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error authenticating with Google: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    self.isSignedIn = true
                }
            }
        }
    }

    func logOut(completion: @escaping (Result<Void, Error>) -> Void) {
        print("LogOut function called")
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isSignedIn = false
                print("Successfully signed out")
                completion(.success(()))
            }
        } catch let error as NSError {
            DispatchQueue.main.async {
                print("Sign out error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    func resetData(completion: @escaping (Result<Void, Error>) -> Void) {
        FirebaseManager.shared.resetUserData { result in
            completion(result)
        }
    }
}
