import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class GoogleAuthHandler {
    static func reauthenticateWithGoogle(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "Google client ID not found", code: 0, userInfo: nil)))
            return
        }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            completion(.failure(NSError(domain: "Root view controller not found", code: 0, userInfo: nil)))
            return
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = signInResult?.user else {
                completion(.failure(NSError(domain: "Error with Google authentication", code: 0, userInfo: nil)))
                return
            }

            guard let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "Error retrieving idToken", code: 0, userInfo: nil)))
                return
            }

            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
