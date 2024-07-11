import SwiftUI
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import Combine
import FirebaseAuth

class AuthViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @Published var isSignedIn: Bool = Auth.auth().currentUser != nil
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    internal var reauthenticationCompletion: ((Result<Void, Error>) -> Void)? // Add this property
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        addAuthStateListener()
    }

    deinit {
        removeAuthStateListener()
    }

    private func addAuthStateListener() {
        removeAuthStateListener()
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            DispatchQueue.main.async {
                self.isSignedIn = user != nil
                print("Auth state changed: \(self.isSignedIn)")
            }
        }
    }

    private func removeAuthStateListener() {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            authStateListenerHandle = nil
        }
    }

    func signOut() -> AnyPublisher<Void, Error> {
        Future { promise in
            do {
                try Auth.auth().signOut()
                DispatchQueue.main.async {
                    self.isSignedIn = false
                    print("Successfully signed out")
                    promise(.success(()))
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                    print("Sign out error: \(error.localizedDescription)")
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func resetData() -> AnyPublisher<Void, Error> {
        Future { promise in
            FirebaseManager.shared.resetUserData { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Successfully reset user data")
                        promise(.success(()))
                    case .failure(let error):
                        print("Reset data error: \(error.localizedDescription)")
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteUserAccount() -> AnyPublisher<Void, Error> {
        guard let user = Auth.auth().currentUser else {
            return Fail(error: NSError(domain: "No user found", code: 0, userInfo: nil)).eraseToAnyPublisher()
        }

        return reauthenticate()
            .flatMap { [unowned self] in self.resetData() }
            .flatMap { _ in
                Future<Void, Error> { promise in
                    user.delete { error in
                        if let error = error {
                            print("Delete account error: \(error.localizedDescription)")
                            promise(.failure(error))
                        } else {
                            DispatchQueue.main.async {
                                self.isSignedIn = false
                                print("Successfully deleted account")
                                promise(.success(()))
                            }
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    private func reauthenticate() -> AnyPublisher<Void, Error> {
        Future { promise in
            guard let user = Auth.auth().currentUser else {
                promise(.failure(NSError(domain: "No user found", code: 0, userInfo: nil)))
                return
            }

            if let providerData = user.providerData.first {
                let providerID = providerData.providerID
                print("Reauthenticate with provider: \(providerID)")

                switch providerID {
                case "apple.com":
                    AppleAuthHandler.startSignInWithAppleFlow(viewModel: self) { result in
                        promise(result)
                    }
                case "google.com":
                    GoogleAuthHandler.reauthenticateWithGoogle { result in
                        promise(result)
                    }
                case "password":
                    EmailAuthHandler.reauthenticateWithPassword { result in
                        promise(result)
                    }
                default:
                    promise(.failure(NSError(domain: "Unknown provider ID", code: 0, userInfo: nil)))
                }
            } else {
                promise(.failure(NSError(domain: "No provider data found", code: 0, userInfo: nil)))
            }
        }
        .eraseToAnyPublisher()
    }


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

    @objc func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        AppleAuthHandler.authorizationController(viewModel: self, controller: controller, didCompleteWithAuthorization: authorization)
    }

    @objc func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        AppleAuthHandler.authorizationController(viewModel: self, controller: controller, didCompleteWithError: error)
    }

    @objc func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            fatalError("No window scene found")
        }
        return windowScene.windows.first { $0.isKeyWindow }!
    }
}
